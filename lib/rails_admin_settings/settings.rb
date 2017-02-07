require 'thread'

# we are inheriting from BasicObject so we don't get a bunch of methods from
# Kernel or Object
class Settings < BasicObject

  DELEGATE = [:puts, :p, :block_given?].freeze

  cattr_accessor :file_uploads_supported, :file_uploads_engine
  @@file_uploads_supported = false
  @@file_uploads_engine = false
  @@namespaces = {}
  @@mutex = ::Mutex.new

  @@ns_default = 'main'
  @@ns_fallback = nil
  cattr_accessor :ns_default, :ns_fallback, :namespaces

  cattr_reader :mutex

  class << self
    def ns(name, options = {})
      options.symbolize_keys!
      if name.nil? || name == @@ns_default
        name = @@ns_default.to_s
      else
        name = name.to_s
      end
      if options.key?(:type)
        options[:kind] = options.delete(:type)
      end
      @@mutex.synchronize do
        @@namespaces[name] ||= ::RailsAdminSettings::Namespaced.new(name.to_s)
      end
      fallback = options.key?(:fallback) ? options[:fallback] : @@ns_fallback
      ::RailsAdminSettings::Fallback.new(@@namespaces[name], fallback)
    end

    def get_default_ns
      ns(nil, fallback: @@ns_fallback)
    end

    def table_exists?
      RailsAdminSettings.mongoid? || RailsAdminSettings::Setting.table_exists?
    end

    def unload!
      @@mutex.synchronize do
        @@namespaces.values.map(&:unload!)
        @@namespaces = {}
        @@ns_default = 'main'
        @@ns_fallback = nil
      end
    end

    def destroy_all!
      RailsAdminSettings::Setting.destroy_all
      unload!
    end

    def root_file_path
      if Object.const_defined?('Rails')
        Rails.root
      else
        Pathname.new(File.dirname(__FILE__)).join('../..')
      end
    end

    def apply_defaults!(file, verbose = false)
      if File.file?(file)
        puts "[settings] Loading from #{file}".freeze if verbose
        yaml = YAML.load(File.read(file), safe: true)
        yaml.each_pair do |namespace, vals|
          vals.symbolize_keys!
          n = ns(namespace)
          vals.each_pair do |key, val|
            val.symbolize_keys!
            if !val[:kind].nil? && (val[:kind] == 'file' || val[:kind] == 'image')
              unless @@file_uploads_supported
                ::Kernel.raise ::RailsAdminSettings::PersistenceException, "Fatal: setting #{key} is #{val[:type]} but file upload engine is not detected".freeze
              end
              value = File.open(root_file_path.join(val.delete(:value)))
            else
              value = val.delete(:value)
            end
            puts "#{key} - default '#{value}' current '#{Settings.get(key).raw}'".freeze if verbose
            n.set(key, value, val.merge(overwrite: false))
          end
          n.unload!
        end
      end
    end

    def get(key, options = {})
      options.symbolize_keys!
      ns(options[:ns], options).get(key, options)
    end

    def set(key, value = nil, options = {})
      options.symbolize_keys!
      ns(options[:ns], options).set(key, value, options)
    end

    def save_default(key, value, options = {})
      set(key, value, options.merge(overwrite: false))
    end

    def create_setting(key, value, options = {})
      set(key, nil, options.merge(overwrite: false))
    end

    def method_missing(name, *args, &block)
      return ::Kernel.send(name, *args, &block) if DELEGATE.include?(name)
      get_default_ns.__send__(name, *args, &block)
    end

    def respond_to_missing?(name, include_private = false)
      DELEGATE.include?(name) or super
    end
  end
end
