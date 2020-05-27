module RailsAdminSettings
  module Cache
    extend ActiveSupport::Concern
    included do
      
      def cache_keys
        @cache_keys ||= (cache_keys_str || "").split(/\s+/).map { |k| k.strip }.reject { |k| k.blank? }
      end
      def add_cache_key(_key)
        unless has_cache_key?(_key)
          self.cache_keys_str = (cache_keys + [_key]).uniq.join(" ")
          @cache_key = nil
        end
      end
      def has_cache_key?(_key)
        cache_keys.include?(_key)
      end

      after_touch :clear_cache
      after_save :clear_cache
      after_destroy :clear_cache
      def clear_cache
        cache_keys.each do |k|
          Rails.cache.delete(k)
        end
      end

    end
  end
end
