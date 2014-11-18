module Yaks
  class Mapper
    class Control
      extend Util::Deprecated
      include Attributes.new(
                name: nil, action: nil, title: nil, method: nil, media_type: nil, fields: []
              ),
              Configurable

      alias enctype media_type
      deprecated_alias :href, :action

      def self.create(name = nil, options = {})
        new({name: name}.merge(options))
      end

      def add_to_resource(resource, mapper, _context)
        resource.add_control(to_resource(mapper))
      end

      def to_resource(mapper)
        attrs = {
          fields: resource_fields(mapper),
          action: mapper.expand_uri(action, true)
        }
        [:name, :title, :method, :media_type].each do |attr|
          attrs[attr] = mapper.expand_value(public_send(attr))
        end
        Resource::Control.new(attrs)
      end

      def resource_fields(mapper)
        fields.map { |field| field.to_resource(mapper) }
      end

      class Field
        include Attributes.new(:name, label: nil, type: "text", value: nil, options: []),
                Configurable

        def self.create(*args, &block)
          attrs = args.last.instance_of?(Hash) ? args.pop : {}
          if name = args.shift
            attrs = attrs.merge(name: name)
          end
          new(attrs)
        end

        def to_resource(mapper)
          Resource::Control::Field.new(
            [:name, :label, :type, :value].each_with_object({}) do |attr, attrs|
              attrs[attr] = mapper.expand_value(public_send(attr))
            end.merge(options: options.map(&:to_resource))
          )
        end

        class Option
          include Attributes.new(:value, :label, selected: false)

          def self.create(value, opts = {})
            new(opts.merge(value: value))
          end

          def to_resource
            to_h #placeholder
          end
        end

        config_method :option,
                      append_to: :options,
                      create: Option
      end

      FieldBuilder = StatefulBuilder.new(Field, [:name, :label, :type, :value, :option])

      config_method :field, create: FieldBuilder, append_to: :fields

      HTML5Forms::INPUT_TYPES.each do |type|
        config_method type, create: FieldBuilder, append_to: :fields, defaults: { type: type }
      end
    end
  end
end
