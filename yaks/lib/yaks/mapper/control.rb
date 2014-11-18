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

      def add_to_resource(resource, parent_mapper, _context)
        resource.add_control(map_to_resource_control(resource, parent_mapper))
      end

      def map_to_resource_control(resource, parent_mapper)
        attrs = {
          fields: resource_fields,
          action: parent_mapper.expand_uri(action, true)
        }
        Resource::Control.new(to_h.merge(attrs))
      end

      def resource_fields
        fields.map(&:to_resource_field)
      end

      class Field
        include Attributes.new(:name, label: nil, type: "text", value: nil)

        def self.create(*args)
          attrs = args.last.instance_of?(Hash) ? args.pop : {}
          if name = args.shift
            attrs = attrs.merge(name: name)
          end
          new(attrs)
        end

        def to_resource_field
          Resource::Control::Field.new(to_h)
        end
      end

      config_method :field, create: Field, append_to: :fields

      HTML5Forms::INPUT_TYPES.each do |type|
        config_method :field, create: Field, append_to: :fields, defaults: { type: type }
      end
    end
  end
end
