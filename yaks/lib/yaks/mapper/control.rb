module Yaks
  class Mapper
    class Control
      extend Util::Deprecated, Configurable
      include Attributes.new(
                name: nil, action: nil, title: nil, method: nil, media_type: nil, fields: []
              )


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

    end
  end
end
