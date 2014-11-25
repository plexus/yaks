module Yaks
  class Resource
    class Form
      include Yaks::Mapper::Form.attributes

      def [](name)
        fields.find {|field| field.name == name}.value
      end

      def values
        fields.each_with_object({}) do |field, values|
          values[field.name] = field.value
        end
      end

      class Field
        include Yaks::Mapper::Form::Field.attributes.add(:error => nil)

        def value(arg = Undefined)
          return @value if arg.eql?(Undefined)
          if type == :select
            selected = options.find { |option| option.selected }
            selected.value if selected
          else
            update(value: arg)
          end
        end
      end
    end
  end
end
