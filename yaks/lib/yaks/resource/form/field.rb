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

        def with_value(attributes)
          if type.equal? :select
            with(with_select_options(attributes))
          else
            with(attributes)
          end
        end

        private

        def with_select_options(attributes)
          unset = ->(option) { option.selected && !(option.value == attributes[:value]) }
          set   = ->(option) { !option.selected && (option.value == attributes[:value]) }

          new_options = options.reduce([]) do |new_opts, option|
            new_opts << case option
                        when unset
                          option.update selected: false
                        when set
                          option.update selected: true
                        else
                          option
                        end
          end

          attributes.merge(options: new_options)
        end
      end
    end
  end
end
