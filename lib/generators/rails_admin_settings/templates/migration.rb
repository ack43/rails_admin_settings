class CreateRailsAdminSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :rails_admin_settings do |t|
      t.boolean :enabled, default: true
      t.string :kind, null: false, default: 'string'
      t.string :ns, default: 'main'
      t.string :key, null: false
      if Object.const_defined?('Geocoder')
        t.float :latitude
        t.float :longitude
      end
      t.text :raw
      t.string :label
      if defined?(Paperclip)
        t.attachment :file
      elsif defined?(CarrierWave)
        t.string :file
      end

      t.boolean :loadable, default: true
      t.string :cache_keys_str, default: ""


      # t.json :raw_array, default: []
      # t.json :raw_hash, default: {}
      # t.json :possible_array, default: []
      # t.json :possible_hash, default: {}
      # t.json :raw_array, default: []

      t.column :raw_array,      :json, default: []
      t.column :raw_hash,       :json, default: {}
      t.column :possible_array, :json, default: []
      t.column :possible_hash,  :json, default: {}
      t.column :raw_array,      :json, default: []


      t.timestamps
    end

    add_index :rails_admin_settings, :key
    add_index :rails_admin_settings, [:ns, :key, :loadable], unique: true
  end
end
