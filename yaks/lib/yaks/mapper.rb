module Yaks
  class Mapper
    extend Configurable

    def_set :type

    def_forward :attributes => :add_attributes
    def_forward :append_to

    def_add :link,      create: Link,      append_to: :links
    def_add :has_one,   create: HasOne,    append_to: :associations
    def_add :has_many,  create: HasMany,   append_to: :associations
    def_add :attribute, create: Attribute, append_to: :attributes
    def_add :form,      create: Form,      append_to: :forms

    extend Forwardable
    include Util, FP, FP::Callable

    attr_reader :object, :context

    def_delegators 'self.class', :config
    def_delegators :config, :attributes, :links, :associations, :forms

    def initialize(context)
      @context = context
    end

    def policy
      context.fetch(:policy)
    end

    def env
      context.fetch(:env)
    end

    def mapper_stack
      context.fetch(:mapper_stack)
    end

    def self.mapper_name(policy)
      config.type || policy.derive_type_from_mapper_class(self)
    end

    def mapper_name
      self.class.mapper_name(policy)
    end

    def call(object, env = {})
      @object = object

      return NullResource.new if object.nil?

      [ :map_attributes,
        :map_links,
        :map_subresources,
        :map_forms
      ].inject(Resource.new(type: mapper_name)) do |resource, method|
        send(method, resource)
      end
    end

    def load_attribute(name)
      respond_to?(name) ? public_send(name) : object.public_send(name)
    end
    alias load_association load_attribute

    def expand_value(value)
      Resolve(value, self)
    end

    def expand_uri(uri, expand)
      return if uri.nil?
      return Resolve(uri, self) if uri.respond_to?(:to_proc)

      template = URITemplate.new(uri)
      expand_vars = case expand
                    when true
                      template.variables
                    when false
                      []
                    else
                      expand
                    end

      mapping = expand_vars.each_with_object({}) do |name, hsh|
        hsh[name] = load_attribute(name)
      end

      template.expand_partial(mapping).to_s
    end

    private

    def map_attributes(resource)
      attributes.inject(resource) do |res, attribute|
        attribute.add_to_resource(res, self, context)
      end
    end

    def map_links(resource)
      links.inject(resource) do |res, mapper_link|
        mapper_link.add_to_resource(res, self, context)
      end
    end

    def map_subresources(resource)
      associations.inject(resource) do |res, association|
        association.add_to_resource(res, self, context)
      end
    end

    def map_forms(resource)
      forms.inject(resource) do |res, form|
        form.add_to_resource(res, self, context)
      end
    end
  end
end
