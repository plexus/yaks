module Yaks
  class Mapper
    class Form
      ############################################################
      # metaclass

      extend Configurable

      def_set :action, :title, :method, :media_type
      def_add :field, create: Field::Builder, append_to: :fields
      HTML5Forms::INPUT_TYPES.each do |type|
        def_add type, create: Field::Builder, append_to: :fields, defaults: { type: type }
      end
      def_forward :dynamic

      # Duplicated to have a builder for ammending the config with
      # dynamic fields. Will clean it up, I promise
      ConfigBuilder = Builder.new(Config) do
        def_set :action, :title, :method, :media_type
        def_add :field, create: Field::Builder, append_to: :fields
        HTML5Forms::INPUT_TYPES.each do |type|
          def_add type, create: Field::Builder, append_to: :fields, defaults: { type: type }
        end
        def_forward :dynamic
      end

      extend Forwardable

      def_delegators :config, :dynamic_blocks

      def self.create(*args, &block)
        # TODO: worst extract_options eva. Clean this
        # up. Util#extract_options?
        options = args.last
        options = {} unless options.is_a? Hash
        if args.first.is_a? Symbol
          name = options[:name] = args.first
        end

        Class.new(Form).tap do |form_class|
          form_class.config = form_class.config.with(options)

          if name
            form_class.define_singleton_method :name do
              "#{name}:Class(Yaks::Mapper:Form)"
            end
          end

          form_class.define_singleton_method :inspect do
            "#<Class(Yaks::Mapper:Form) #{config.to_h_compact.inspect}>"
          end

          form_class.instance_eval(&block) if block_given?
        end
      end

      ############################################################
      # instance

      include Concord.new(:config)

      def initialize(config = self.class.config)
        super(config)
      end

      def add_to_resource(resource, mapper, _context)
        resource.add_form(to_resource(mapper))
      end

      def to_resource(mapper)
        config = dynamic_blocks.inject(self.config) do |config, block|
          ConfigBuilder.build(config, &block)
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

      def resource_fields(fields, mapper)
        fields.map { |field| field.to_resource(mapper) }
      end

    end
  end
end
