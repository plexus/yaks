module Yaks
  class Mapper
    class Form
      class Field
        include Attribs.new(
                  :name,
                  label: nil,
                  options: [].freeze,
                  if: nil
                ).add(HTML5Forms::FIELD_OPTIONS)

        Builder = Builder.new(self) do
          def_set :name, :label
          def_add :option, create: Option, append_to: :options

          def condition(blk1 = nil, &blk2)
            @config = @config.with(if: blk1 || blk2)
          end

          HTML5Forms::FIELD_OPTIONS.each do |option, _|
            def_set option
          end
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
        def to_resource_fields(mapper)
          return [] if self.if && !mapper.expand_value(self.if)
          [ Resource::Form::Field.new(
              (resource_attributes - [:if]).each_with_object({}) do |attr, attrs|
                attrs[attr] = mapper.expand_value(public_send(attr))
              end.merge(options: resource_options(mapper))) ]
        end

        def resource_options(mapper)
          # make sure all empty options arrays are the same instance,
          # makes for prettier #pp
          options.empty? ? options : options.map {|opt| opt.to_resource_field_option(mapper) }.compact
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
