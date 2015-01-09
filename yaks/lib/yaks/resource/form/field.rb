module Yaks
  class Resource
    class Form
      class Field
        include Yaks::Mapper::Form::Field.attributes.add(:error => nil)

        def value
          if type.equal? :select
            selected = options.find { |option| option.selected }
            selected.value if selected
          else
            @value
          end
        end
      end
    end
  end
end
