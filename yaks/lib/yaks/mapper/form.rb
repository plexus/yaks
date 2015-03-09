module Yaks
  class Mapper
    class Form
      extend Configurable, Forwardable, Util

      ConfigBuilder = Builder.new(Config) do
        def_set :action, :title, :method, :media_type
        def_add :field, create: Field::Builder, append_to: :fields
        def_add :fieldset, create: Fieldset, append_to: :fields
        HTML5Forms::INPUT_TYPES.each do |type|
          def_add(type,
            create: Field::Builder,
            append_to: :fields,
            defaults: { type: type }
          )
        end
        def_forward :dynamic
        def_forward :condition
      end

      def_delegators :config, :name, :action, :title, :method,
                              :media_type, :fields, :dynamic_blocks

      def self.create(*args, &block)
        args, options = extract_options(args)

        if args.first.is_a? Symbol
          options[:name] = args.first
        end

        new(ConfigBuilder.build(Config.new(options), &block))
      end

      ############################################################
      # instance

      include Concord.new(:config)

      def add_to_resource(resource, mapper, _context)
        return resource if config.if && !mapper.expand_value(config.if)
        resource.add_form(to_resource_form(mapper))
      end

      def to_resource_form(mapper)
        config = dynamic_blocks.inject(self.config) do |config, block|
          ConfigBuilder.build(config, mapper.object, &block)
        end

        attrs = {
          fields: resource_fields(config.fields, mapper),
          action: mapper.expand_uri(config.action, true)
        }

        [:name, :title, :method, :media_type].each do |attr|
          attrs[attr] = mapper.expand_value(config.public_send(attr))
        end

        Resource::Form.new(attrs)
      end

      private

      def resource_fields(fields, mapper)
        fields.map {|field| field.to_resource(mapper) }.compact
      end
    end
  end
end
