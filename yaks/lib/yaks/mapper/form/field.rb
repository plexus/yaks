module Yaks
  class Mapper
    class Form
      class Field
        include Attributes.new(
                  :name,
                  label: nil,
                  options: [].freeze
                ).add(HTML5Forms::FIELD_OPTIONS)

        Builder = StatefulBuilder.new(self) do
          def_set :name
          def_set :label
          def_add :option, create: Option, append_to: :options
        end

        def self.create(*args)
          attrs = args.last.instance_of?(Hash) ? args.pop : {}
          if name = args.shift
            attrs = attrs.merge(name: name)
          end
          new(attrs)
        end

        # Convert to a Resource::Form::Field, expanding any dynamic
        # values
        def to_resource(mapper)
          Resource::Form::Field.new(
            resource_attributes.each_with_object({}) do |attr, attrs|
              attrs[attr] = mapper.expand_value(public_send(attr))
            end.merge(options: resource_options)
          )
        end

        def resource_options
          # make sure all empty options arrays are the same instance,
          # makes for prettier #pp
          options.empty? ? options : options.map(&:to_resource)
        end

        # All attributes that can be converted 1-to-1 to
        # Resource::Form::Field
        def resource_attributes
          self.class.attributes.names - [:options]
        end

      end #Field
    end # Form
  end # Mapper
end # Yaks
