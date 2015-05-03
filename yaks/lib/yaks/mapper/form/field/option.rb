module Yaks
  class Mapper
    class Form
      class Field
        # <option>, as used in a <select>
        class Option
          include Attribs.new(:value, :label, selected: false, disabled: false, if: nil)

          def self.create(value, opts)
            new(opts.merge(value: value))
          end

          def to_resource_field_option(mapper)
            return unless self.if.nil? || mapper.expand_value(self.if)

            Resource::Form::Field::Option.new(
              value: mapper.expand_value(value),
              label: mapper.expand_value(label),
              selected: mapper.expand_value(selected),
              disabled: mapper.expand_value(disabled)
            )
          end
        end
      end
    end
  end
end
