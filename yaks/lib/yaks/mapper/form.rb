module Yaks
  class Mapper
    class Form
      extend Forwardable, Util

      def_delegators :config, :name, :action, :title, :method,
                              :media_type, :fields, :dynamic_blocks

      def self.create(*args, &block)
        args, options = extract_options(args)
        options[:name] = args.first if args.first
        new(config: Config.build(options, &block))
      end

      ############################################################
      # instance

      include Attribs.new(:config)

      def add_to_resource(resource, mapper, _context)
        return resource if config.if && !mapper.expand_value(config.if)
        resource.add_form(to_resource_form(mapper))
      end

      def to_resource_form(mapper)
        attrs = {
          fields: config.to_resource_fields(mapper),
          action: mapper.expand_uri(action)
        }

        [:name, :title, :method, :media_type].each do |attr|
          attrs[attr] = mapper.expand_value(public_send(attr))
        end

        Resource::Form.new(attrs)
      end
    end
  end
end
