# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    extend ClassMethods, Forwardable
    include Util, FP

    def_delegators 'self.class', :config
    def_delegators :config, :attributes, :links, :associations, :controls

    config Config.new

    attr_reader :object, :context

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
        :map_controls
      ].inject(Resource.new(type: mapper_name)) do |resource, method|
        send(method, resource)
      end
    end

    def load_attribute(name)
      respond_to?(name) ? public_send(name) : object.public_send(name)
    end
    alias load_association load_attribute

    def expand_uri(uri, expand)
      case uri
      when nil
        return
      when Symbol
        return load_attribute(uri)
      when Method, Proc
        return Resolve(uri, self)
      end

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

    def map_controls(resource)
      controls.inject(resource) do |res, control|
        control.add_to_resource(res, self, context)
      end
    end
  end
end
