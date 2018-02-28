module RailsAdminSettings

  module RailsAdminConfig

    def self.included(base)
      if base.respond_to?(:rails_admin)
        base.rails_admin do
          navigation_label I18n.t('admin.settings.label')

          list do
            if Object.const_defined?('RailsAdminToggleable')
              field :enabled, :toggle
              # field :loadable, :toggle
            else
              field :enabled
              # field :loadable
            end
            field :kind do
              searchable true
            end
            field :ns do
              searchable true
            end
            field :name
            field :label do
              visible false
              searchable true
            end
            field :key do
              searchable true
            end
            field :raw_data do
              pretty_value do
                if bindings[:object].file_kind?
                  "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'>#{CGI::escapeHTML(bindings[:object].to_path)}</a>".html_safe.freeze
                elsif bindings[:object].image_kind?
                  "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'><img src='#{CGI::escapeHTML(bindings[:object].file.url)}' /></a>".html_safe.freeze
                elsif bindings[:object].array_kind?
                  (bindings[:object].raw_array || []).join("<br>").html_safe
                elsif bindings[:object].hash_kind?
                  "<pre>#{JSON.pretty_generate(bindings[:object].raw_hash || {})}</pre>".html_safe
                else
                  value
                end
              end
            end
            field :raw do
              searchable true
              visible false
              pretty_value do
                if bindings[:object].file_kind?
                  "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'>#{CGI::escapeHTML(bindings[:object].to_path)}</a>".html_safe.freeze
                elsif bindings[:object].image_kind?
                  "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'><img src='#{CGI::escapeHTML(bindings[:object].file.url)}' /></a>".html_safe.freeze
                else
                  value
                end
              end
            end
            field :raw_array do
              searchable true
              visible false
              pretty_value do
                (bindings[:object].raw_array || []).join("<br>").html_safe
              end
            end
            field :raw_hash do
              searchable true
              visible false
              pretty_value do
                "<pre>#{JSON.pretty_generate(bindings[:object].raw_hash || {})}</pre>".html_safe
              end
            end
            field :cache_keys_str, :text do
              searchable true
            end
            if ::Settings.table_exists?
              nss = ::RailsAdminSettings::Setting.distinct(:ns).map { |c| "ns_#{c.gsub('-', '_')}".to_sym }
            else
              nss = []
            end
            scopes([nil, :model_settings, :no_model_settings] + nss)
          end

          edit do
            field :enabled
            field :loadable
            field :ns  do
              read_only true
              help false
            end
            field :key  do
              read_only true
              help false
            end
            field :label do
              read_only true
              help false
            end
            field :kind do
              read_only true
              help false
            end
            field :raw do
              partial "setting_value".freeze
              visible do
                !bindings[:object].upload_kind? and !bindings[:object].array_kind? and !bindings[:object].hash_kind?
              end
            end
            field :raw_array do
              partial "setting_value".freeze
              pretty_value do
                (bindings[:object].raw_array || []).map(&:to_s).join("<br>").html_safe
              end
              visible do
                bindings[:object].array_kind?
              end
            end
            field :raw_hash do
              partial "setting_value".freeze
              pretty_value do
                "<pre>#{JSON.pretty_generate(bindings[:object].raw_hash || {})}</pre>".html_safe
              end
              visible do
                bindings[:object].hash_kind?
              end
            end
            if Settings.file_uploads_supported
              field :file, Settings.file_uploads_engine do
                visible do
                  bindings[:object].upload_kind?
                end
              end
            end

            field :cache_keys_str, :text do
              visible do
                render_object = (bindings[:controller] || bindings[:view])
                render_object and render_object.current_user.admin?
              end
            end

          end
        end
      else
        puts "[rails_admin_settings] Problem: model does not respond to rails_admin: this should not happen"
      end
    end

  end

end
