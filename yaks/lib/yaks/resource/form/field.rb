module Yaks
  class Resource
    class Form
      class Field
        include Yaks::Mapper::Form::Field.attributes.add(:error => nil)

        def value
          if type.equal? :select
            selected = options.find(&:selected)
            selected.value if selected
          else
            @value
          end
        end

        def with_value(value)
          if type.equal? :select
            with(options: select_options_for_value(value))
          else
            with(value: value)
          end
        end

        private

        def select_options_for_value(value)
          unset = ->(option) { option.selected && !value().eql?(value) }
          set   = ->(option) { !option.selected && option.value.eql?(value) }

          options.each_with_object([]) do |option, new_opts|
            new_opts << case option
                        when unset
                          option.update selected: false
                        when set
                          option.update selected: true
                        else
                          option
                        end
          end
        end
      end
    end
  end
end
