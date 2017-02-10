module RailsAdminSettings
  # we are inheriting from BasicObject so we don't get a bunch of methods from
  # Kernel or Object
  class Namespaced < BasicObject

    DELEGATE = [:puts, :p, :block_given?].freeze

    attr_accessor :settings, :fallback
    attr_reader :loaded, :mutex, :ns_mutex, :name

    def initialize(name)
      self.settings = {}
      @mutex = ::Mutex.new
      @ns_mutex = ::Mutex.new
      @loaded = false
      @locked = false
      @name = name
    end

    def nil?
      false
    end
    def inspect
      "#<RailsAdminSettings::Namespaced name: #{@name.inspect}, fallback: #{@fallback.inspect}, loaded: #{@loaded}>".freeze
    end
    def pretty_inspect
      inspect
    end

    def load!
      mutex.synchronize do
        return if loaded
        @loaded = true
        @settings = {}
        ::RailsAdminSettings::Setting.ns(@name).loadable.each do |setting|
          @settings[setting.key] = setting
        end
      end
    end

    def unload!
      mutex.synchronize do
        @loaded = false
        @settings = {}
      end
    end

    # returns setting object
    def get(key, options = {}, &block)
      options[:loadable] = true unless options[:loadable] == false
      load! if options[:loadable]
      key = key.to_s
      mutex.synchronize do
        @locked = true
        _loadable = options[:loadable]
        unless _loadable
          v = ::RailsAdminSettings::Setting.ns(name).where(key: key).first
          if v
            unless options[:cache_keys_str].present?
              _cache_keys = options.delete(:cache_keys)
              _cache_keys ||= options.delete(:cache_key)

              if _cache_keys.nil?
                options[:cache_keys_str] = ""
                # if _cache
                #   options[:cache_keys_str] = name.underscore
                # end
              else
                if _cache_keys.is_a?(::Array)
                  options[:cache_keys_str] = _cache_keys.map { |k| k.to_s.strip }.join(" ")
                else
                  options[:cache_keys_str] = _cache_keys.to_s.strip
                end
              end
            end
            options.delete(:cache_keys)
            options.delete(:cache_key)

            _old_cache_keys = options[:cache_keys_str].strip.split(" ")
            # options[:cache_keys_str] = ("#{v.cache_keys_str} #{(options[:cache_keys_str] || "")}".strip.split(" ")).uniq
            # options[:cache_keys_str] = ("#{v.cache_keys_str.join(" ")} #{(options[:cache_keys_str] || "")}".strip.split(" ")).uniq
            options[:cache_keys_str] = (_old_cache_keys + v.cache_keys).uniq
            options[:overwrite] = true if (options[:cache_keys_str] - _old_cache_keys).blank?
            options[:cache_keys_str] = options[:cache_keys_str].map { |k| k.to_s.strip }.join(" ")
          end
        else
          v = @settings[key]
        end
        _overwrite = options[:overwrite]
        if v.nil? or _overwrite
          if v.nil?
            unless @fallback.nil? || @fallback == @name
              v = ::Settings.ns(@fallback).getnc(key)
            end
          end
          if v.nil? or _overwrite
            if block
              begin
                v = set(key, yield, options)
              rescue Exception => ex
                # puts "WTF"
                # puts ex.inspect
              end
            else
              v = set(key, options[:default], options)
            end
          end
        end
        @locked = false
        v
      end
    end

    # returns setting object
    def getnc(key)
      load!
      ret = mutex.synchronize do
        self.settings[key]
      end
      unless ret
        ret = ::RailsAdminSettings::Setting.ns(name).where(key: key).first
      end
      ret
    end

    def set(key, value = nil, options = {})
      load! unless @locked if options[:loadable]
      key = key.to_s
      options.symbolize_keys!
      if options.key?(:cache)
        _cache = options.delete(:cache)
      else
        _cache = (name != ::Settings.ns_default)
      end

      if !options[:type].nil? && options[:type] == 'yaml' && !value.nil?
        if value.class.name != 'String'
          value = value.to_yaml
        end
      end

      unless options[:cache_keys_str].present?
        _cache_keys = options.delete(:cache_keys)
        _cache_keys ||= options.delete(:cache_key)

        if _cache_keys.nil?
          # if _cache
          #   options[:cache_keys_str] = name.underscore
          # end
        else
          if _cache_keys.is_a?(::Array)
            options[:cache_keys_str] = _cache_keys.map { |k| k.to_s.strip }.join(" ")
          else
            options[:cache_keys_str] = _cache_keys.to_s.strip
          end
        end
      end
      options.delete(:cache_keys)
      options.delete(:cache_key)

      options.merge!(value: value)
      if @locked
        ret = write_to_database(key, options)
      else
        mutex.synchronize do
          ret = write_to_database(key, options)
        end
      end
      ret
    end

    def enabled?(key, options = {})
      get(key, options).enabled?
    end

    def []=(key, value)
      set(key, value)
    end
    def [](key)
      get(key)
    end

    def destroy!(key)
      load!
      key = key.to_s
      mutex.synchronize do
        ::RailsAdminSettings::Setting.where(ns: @name, key: key).destroy_all
        @settings.delete(key)
      end
    end

    def destroy_all!
      mutex.synchronize do
        ::RailsAdminSettings::Setting.where(ns: @name).destroy_all
        @loaded = false
        @settings = {}
      end
    end

    # returns processed setting value
    def method_missing(key, *args, &block)
      return ::Kernel.send(key, *args, &block) if DELEGATE.include?(key)
      key = key.to_s
      if key.end_with?('_enabled?')
        key = key[0..-10]
        v = get(key)
        if v.nil?
          set(key, '').enabled
        else
          v.enabled
        end
      elsif key.end_with?('_enabled=')
        key = key[0..-10]
        v = get(key)
        if ::RailsAdminSettings.mongoid?
          if ::Mongoid::VERSION >= "4.0.0"
            v.set(enabled: args.first)
          else
            v.set("enabled", args.first)
          end
        else
          v.enabled = args.first
          v.save!
        end
        v.enabled
      elsif key.end_with?('=')
        key = key[0..-2]
        options = args[1] || {}
        value = args.first
        set(key, value, options).val
      else
        v = get(key, args.first || {}, &block)
        if v.nil?
          ''
        else
          v.val
        end
      end
    end

    def write_to_database(key, options)
      is_file = !options[:kind].nil? && (options[:kind] == 'image' || options[:kind] == 'file')
      if is_file
        options[:raw] = ''
        file = options[:value]
      else
        options[:raw] = options[:value] if options[:value]
      end

      options.delete(:value)
      options.delete(:default)
      options[:ns] = @name
      if @settings[key].nil?
        if options.delete(:overwrite)
          v = ::RailsAdminSettings::Setting.ns(options[:ns]).where(key: key).first
          if v
            opts = options.dup
            v.update_attributes!(opts)
          end
        end
        if v.nil?
          v = ::RailsAdminSettings::Setting.create(options.merge(key: key))
          if !v.persisted?
            if v.errors[:key].any?
              v = ::RailsAdminSettings::Setting.where(key: key).first
              if v.nil?
                ::Kernel.raise ::RailsAdminSettings::PersistenceException, 'Fatal: error in key and not in DB'
              end
            else
              ::Kernel.raise ::RailsAdminSettings::PersistenceException, v.errors.full_messages.join(',')
            end
          end
        end
        if options[:loadable]
          @settings[key] = v
        else
          return v
        end
      else
        opts = options.dup
        if options[:overwrite] == false && !@settings[key].value.blank?
          opts.delete(:raw)
          opts.delete(:value)
          opts.delete(:enabled)
        end
        opts.delete(:overwrite)
        @settings[key].update_attributes!(opts)
      end
      if is_file and options[:loadable] and @settings[key]
        if options[:overwrite] != false || !@settings[key].file?
          @settings[key].file = file
          @settings[key].save!
        end
      end
      @settings[key]
    end
  end
end
