module Yaks
  class Resource
    class Form
      include Yaks::Mapper::Form::Config.attributes.remove(:dynamic_blocks)

      def [](name)
        fields.find {|field| field.name == name}.value
      end

      def values
        fields_flat.each_with_object({}) do |field, values|
          values[field.name] = field.value
        end
      end

      def fields_flat(fields = fields)
        fields.each_with_object([]) do |field, acc|
          if field.type == :fieldset
            acc.concat(fields_flat field.fields)
          else
            acc << field
          end
        end
      end
    end
  end
end
