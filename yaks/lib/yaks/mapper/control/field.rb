module Yaks
  class Mapper
    class Control
      class Field
        extend Configurable
        include Attributes.new(
                  :name,
                  label: nil,
                  options: []
                ).add(HTML5Forms::FIELD_OPTIONS)

        Builder = StatefulBuilder.new(self, attributes.names)

        def self.create(*args)
          attrs = args.last.instance_of?(Hash) ? args.pop : {}
          if name = args.shift
            attrs = attrs.merge(name: name)
          end
          new(attrs)
        end

        # Convert to a Resource::Control::Field, expanding any dynamic
        # values
        def to_resource(mapper)
          Resource::Control::Field.new(
            resource_attributes.each_with_object({}) do |attr, attrs|
              attrs[attr] = mapper.expand_value(public_send(attr))
            end.merge(options: options.map(&:to_resource))
          )
        end

        # All attributes that can be converted 1-to-1 to
        # Resource::Control::Field
        def resource_attributes
          self.class.attributes.names - [:options]
        end

        # <option>, as used in a <select>
        class Option
          include Attributes.new(:value, :label, selected: false)

          def self.create(value, opts = {})
            new(opts.merge(value: value))
          end

          def to_resource
            to_h #placeholder
          end
        end

        config_method :option, create: Option, append_to: :options
      end #Field

      config_method :field, create: Field::Builder, append_to: :fields

      HTML5Forms::INPUT_TYPES.each do |type|
        config_method type, create: Field::Builder, append_to: :fields, defaults: { type: type }
      end

    end # Control
  end # Mapper
end # Yaks
