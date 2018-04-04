module RailsAdminSettings
  module HashArraySupport
    extend ActiveSupport::Concern
    included do

      def raw_data
        if array_kind?
          raw_array
        elsif hash_kind?
          raw_hash
        else
          raw
        end
      end

      # def possible_data
      #   return @possible_data if @possible_data
      #   if array_kind? or enum_kind?
      #     @possible_data = possible_array
      #   elsif hash_kind?
      #     @possible_data = possible_hash
      #   else
      #     @possible_data = []
      #   end
      #   @possible_data
      # end
      # def possible_data=(data)
      #   if array_kind? or enum_kind?
      #     self.possible_array = data
      #   elsif hash_kind?
      #     self.possible_hash = data
      #   else
      #     data
      #   end
      # end
      def possible_data
        @possible_data ||= (possible_hash.blank? ? (possible_array || []) : (possible_hash || {}))
      end
      def possible_data=(data)
        if array_kind? or enum_kind? or data.is_a?(Array)
          self.possible_array = data
        elsif hash_kind? or data.is_a?(Hash)
          self.possible_hash = data
        else
          data
        end
      end

      def full_possible_data
        if custom_enum_kind?
          _possible_data = possible_data
          if _possible_data.is_a?(Array)
            if multiple_enum_kind?
              ((raw_array || []) + _possible_data).map(&:to_s).uniq
            else
              _possible_data.unshift(value).map(&:to_s).uniq
            end
          else
            (value.blank? ? _possible_data : _possible_data.reverse_merge({"#{value}": value}))
          end
        elsif enum_kind?
          possible_data
        else
          []
        end
      end
      def possible_data_blank?
        possible_data.blank?
      end


      validate :check_value_in_full_possible_data, unless: :possible_data_blank?
      def check_value_in_full_possible_data
        _full_possible_data = full_possible_data
        if _full_possible_data.is_a?(Array)
          if value.is_a?(Array)
            if value.size == (value & _full_possible_data)
              return true
            end
          else
            if _full_possible_data.map(&:to_s).include?(value)
              return true
            end
          end
          self.errors.add(:raw, "Недопустимое значение")
          self.errors.add(:raw_array, "Недопустимое значение")
        elsif _full_possible_data.is_a?(Hash)
          _full_possible_data = _full_possible_data.keys.map(&:to_s)
          if value.is_a?(Array)
            if value.size == (value & _full_possible_data)
              return true
            end
          else
            if _full_possible_data.map(&:to_s).include?(value)
              return true
            end
          end
          self.errors.add(:raw, "Недопустимое значение")
          self.errors.add(:raw_array, "Недопустимое значение")
        end
      end

    end
  end
end
