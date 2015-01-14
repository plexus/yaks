module Yaks
  class Resource
    module MapFields
      def map_fields(fields = fields, &block)
        with(
          fields: fields.map do |field|
            if field.type.equal? :fieldset
              field.map_fields(&block)
            else
              block.call(field)
            end
          end
        )
      end
    end
  end
end
