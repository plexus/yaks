module Yaks
  class Mapper
    class Form
      extend Configurable
      def_set :action, :title, :method, :media_type
      def_add :field, create: Field::Builder, append_to: :fields
      HTML5Forms::INPUT_TYPES.each do |type|
        def_add type, create: Field::Builder, append_to: :fields, defaults: { type: type }
      end

      extend Forwardable
      def_delegators 'self.class', :config
      def_delegators :config, :name, :action, :title, :method, :media_type, :fields

      include Equalizer.new(:config)

      def self.create(*args, &block)
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

      def add_to_resource(resource, mapper, _context)
        resource.add_form(to_resource(mapper))
      end

      def to_resource(mapper)
        attrs = {
          fields: resource_fields(mapper),
          action: mapper.expand_uri(action, true)
        }
        [:name, :title, :method, :media_type].each do |attr|
          attrs[attr] = mapper.expand_value(public_send(attr))
        end
        Resource::Form.new(attrs)
      end

      def resource_fields(mapper)
        fields.map { |field| field.to_resource(mapper) }
      end

    end
  end
end
