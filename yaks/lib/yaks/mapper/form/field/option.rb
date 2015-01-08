module Yaks
  class Mapper
    class Form
      class Field
        # <option>, as used in a <select>
        class Option
          include Attributes.new(:value, :label, selected: false)

          def self.create(value, opts = {})
            new(opts.merge(value: value))
          end

          def to_resource
            Resource::Form::Field::Option.new(to_h)
          end
        end
      end
    end
  end
end
