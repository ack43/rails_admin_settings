module RailsAdminSettings
  module Mongoid
    extend ActiveSupport::Concern
    included do
      include ::Mongoid::Document
      include ::Mongoid::Timestamps::Short

      store_in collection: "rails_admin_settings".freeze
      field :enabled, type: ::Mongoid::VERSION.to_i < 4 ? Boolean : ::Mongoid::Boolean, default: true
      field :kind, type: String, default: RailsAdminSettings.types.first
      field :ns, type: String, default: 'main'
      field :key, type: String
      field :raw, type: String
      field :label, type: String
      index({ns: 1, key: 1}, {unique: true, sparse: true})

      field :cache_keys_str, type: String, default: ""
      def cache_keys
        cache_keys_str.split(/\s+/).map { |k| k.strip }.reject { |k| k.blank? }
      end

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
