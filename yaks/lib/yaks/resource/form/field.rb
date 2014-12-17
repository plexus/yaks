module Yaks
  class Resource
    class Form
      class Field
        include Yaks::Mapper::Form::Field.attributes.add(:error => nil)

        def value(arg = Undefined)
          return @value if arg.eql?(Undefined)
          if type == :select
            selected = options.find { |option| option.selected }
            selected.value if selected
          else
            with(value: arg)
          end
        end
      end
    end
  end
end
