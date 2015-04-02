module Yaks
  class Resource
    module HasFields
      def map_fields(&block)
        with(
          fields: fields_flat(&block)
        )
      end

      def fields_flat(&block)
        return to_enum(__method__) unless block_given?
        fields.map do |field|
          next field if field.type.equal? :legend
          if field.respond_to?(:map_fields)
            field.map_fields(&block)
          else
            block.call(field)
          end
        end
      end
    end
  end
end
