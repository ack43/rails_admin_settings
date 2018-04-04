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
      field :raw_array, type: Array
      field :raw_hash, type: Hash
      field :possible_array, type: Array
      field :possible_hash, type: Hash
      field :label, type: String
      field :loadable, type: Boolean, default: true

      index({ns: 1, key: 1, loadable: 1}, {unique: true, sparse: true})

      field :cache_keys_str, type: String, default: ""

      scope :model_settings, -> {
        where(ns: /^rails_admin_model_settings_/)
      }
      scope :no_model_settings, -> {
        where(:ns => /^(?!rails_admin_model_settings_)/)
      }

    end
  end
end
