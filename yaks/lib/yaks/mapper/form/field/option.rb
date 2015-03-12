module Yaks
  class Mapper
    class Form
      class Field
        # <option>, as used in a <select>
        class Option
          include Attributes.new(:value, :label, selected: false, disabled: false, if: nil)

          def self.create(value, opts = {})
            new(opts.merge(value: value))
          end

          def to_resource_field_option(mapper)
            return if self.if && !mapper.expand_value(self.if)
            Resource::Form::Field::Option.new(
              value: mapper.expand_value(value),
              label: mapper.expand_value(label),
              selected: mapper.expand_value(selected),
              disabled: mapper.expand_value(disabled),
            )
          end
        end
      end
    end
  end
end
