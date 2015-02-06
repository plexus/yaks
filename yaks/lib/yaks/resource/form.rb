module Yaks
  class Resource
    class Form
      include Yaks::Mapper::Form::Config.attributes.remove(:dynamic_blocks)
      include Yaks::Resource::HasFields

      def [](name)
        fields.find {|field| field.name.equal? name}.value
      end

      def values
        fields_flat.each_with_object({}) do |field, values|
          values[field.name] = field.value
        end
      end

      def fields_flat(fs = fields)
        fs.each_with_object([]) do |field, acc|
          if field.type.equal? :fieldset
            acc.concat(fields_flat field.fields)
          else
            acc << field
          end
        end
      end

      def method?(meth)
        !method.nil? && method.downcase.to_sym === meth.downcase.to_sym
      end

      def has_action?
        !action.nil?
      end
    end
  end
end
