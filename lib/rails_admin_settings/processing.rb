module RailsAdminSettings
  module Processing
    RailsAdminSettings.kinds.each do |dkind|
      define_method "#{dkind}_kind?" do
        dkind == kind
      end
      define_method "#{dkind}_type?" do
        dkind == kind
      end
    end

    def text_kind?
      (RailsAdminSettings.kinds - ['phone', 'phones', 'integer', 'yaml', 'boolean']).include? kind
    end

    def upload_kind?
      ['file', 'image'].include? kind
    end

    def html_kind?
      ['html', 'code', 'sanitized'].include? kind
    end
    alias_method :text_type?, :text_kind?
    alias_method :upload_type?, :upload_kind?
    alias_method :html_type?, :html_kind?

    def array_kind?
      ['array'].include?(kind) or multiple_enum_kind?
    end
    # def hash_kind?
    #   ['hash'].include? kind
    # end

    def enum_kind?
      ['enum', 'custom_enum', 'multiple_enum', 'multiple_custom_enum'].include? kind
    end
    def custom_enum_kind?
      ['custom_enum', 'multiple_custom_enum'].include? kind
    end
    def multiple_enum_kind?
      ['multiple_enum', 'multiple_custom_enum'].include? kind
    end

    def value
      if upload_kind?
        if file_kind?
          file
        else
          nil
        end
      elsif array_kind?
        raw_array
      elsif hash_kind?
        raw_hash
      elsif raw.blank? || disabled?
        default_value
      else
        processed_value
      end
    end

    def blank?
      if file_kind?
        file.blank?
      elsif disabled?
        true
      elsif array_kind?
        raw_array.blank?
      elsif hash_kind?
        raw_hash.blank?
      elsif raw.blank?
        true
      else
        false
      end
    end

    def to_s
      if yaml_kind? || phone_kind? || integer_kind?
        raw
      elsif array_kind?
        if multiple_enum_kind? and !possible_hash.blank?
          raw_array.map { |r| possible_hash[r.to_s] || possible_hash[r.to_sym] }.join(", ")
        else
          raw_array.join(", ")
        end
      elsif hash_kind?
        raw_hash.to_json
      else
        value
      end
    end

    private

    def sanitize_value
      require_sanitize do
        self.raw = Sanitize.clean(value, Sanitize::Config::RELAXED)
      end
    end

    def default_value
      if html_kind?
        ''.html_safe
      elsif text_kind?
        ''
      elsif integer_kind?
        0
      elsif yaml_kind?
      elsif boolean_kind?
        false
      elsif yaml_type?
        nil
      elsif phone_kind?
        require_russian_phone do
          RussianPhone::Number.new('')
        end
      elsif phones_kind?
        []
      elsif array_kind?
        []
      elsif hash_kind?
        {}
      else
        nil
      end
    end

    def default_serializable_value
      if phones_kind? or array_kind? or hash_kind?
        ''
      elsif boolean_type?
        'false'
      else
        default_value
      end
    end

    def process_text
      text = raw.dup
      text.gsub!'{{year}}' do
        Time.now.strftime('%Y')
      end
      text.gsub! /\{\{year\|([\d]{4})\}\}/ do
        if Time.now.strftime('%Y') == $1
          $1
        else
          "#{$1}-#{Time.now.strftime('%Y')}"
        end
      end
      text = text.html_safe if html_kind?
      text
    end

    def load_phone
      require_russian_phone do
        RussianPhone::Number.new(raw)
      end
    end

    def load_phones
      require_russian_phone do
        raw.gsub("\r", '').split("\n").map{|i| RussianPhone::Number.new(i)}
      end
    end

    def load_yaml
      require_safe_yaml do
        YAML.safe_load(raw)
      end
    end

    def processed_value
      if text_kind?
        process_text
      elsif integer_kind?
        raw.to_i
      elsif yaml_kind?
        load_yaml
      elsif boolean_kind?
        raw == 'true'
      elsif phone_kind?
        load_phone
      elsif phones_kind?
        load_phones
      elsif file_kind?
        file.url
      elsif array_kind?
        raw_array
      elsif hash_kind?
        raw_hash
      elsif enum_kind? and !possible_hash.blank?
        if multiple_enum_kind?
          raw_array.map { |r| possible_hash[r.to_s] || possible_hash[r.to_sym] }
        else
          possible_hash[raw.to_s] || possible_hash[raw.to_sym] || raw
        end
      else
        puts "[rails_admin_settings] Unknown field kind: #{kind}".freeze
        nil
      end
    end

    def self.included(base)
      base.class_eval do
        alias_method :val, :value
      end
    end
  end
end
