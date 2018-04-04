module RailsAdminSettings
  module ActiveRecord
    extend ActiveSupport::Concern
    included do

      self.table_name = "rails_admin_settings".freeze


      scope :model_settings, -> {
        # where('`ns` REGEXP ?', '^rails_admin_model_settings_')
        where('`ns` RLIKE ?', '^rails_admin_model_settings_')
      }
      scope :no_model_settings, -> {
        # where('`ns` NOT REGEXP ?', '^rails_admin_model_settings_')
        where('`ns` NOT RLIKE ?', '^rails_admin_model_settings_')
      }


      [:raw_array, :raw_hash, :possible_array, :possible_hash].each do |meth|
        define_method meth do
          JSON.parse(self[meth]) rescue meth.to_s.split("_")[1].capitalize.constantize.new
        end
      end

    end
  end
end
