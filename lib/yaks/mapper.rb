# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    extend ClassMethods, Forwardable
    include Util, FP

    def_delegators 'self.class', :config
    def_delegators :config, :attributes, :links, :associations

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

    def call(object)
      @object = object

      return NullResource.new if object.nil?

      [ :map_attributes,
        :map_links,
        :map_subresources
      ].inject(Resource.new(type: mapper_name)) do |resource, method|
        send(method, resource)
      end
    end

    def map_attributes(resource)
      resource.update_attributes(
        filter(attributes).each_with_object({}) do |attr, memo|
          memo[attr] = load_attribute(attr)
        end
      )
    end

    def map_links(resource)
      links.inject(resource) do |resource, mapper_link|
        resource_link = mapper_link.map_to_resource_link(self)
        next resource unless resource_link
        resource.add_link(resource_link)
      end
    end

    def map_subresources(resource)
      attributes   = filter(associations.map(&:name))
      associations = associations().select{|assoc| attributes.include? assoc.name }

      associations.inject(resource) do |resource, association|
        association.add_to_resource(
          resource,
          self,
          method(:load_association),
          context.merge(mapper_stack: mapper_stack + [self])
        )
      end
    end

    def load_attribute(name)
      respond_to?(name) ? public_send(name) : object.public_send(name)
    end
    alias load_association load_attribute

    def filter(attrs)
      attrs
    end

    def mapper_name
      config.type || policy.derive_type_from_mapper_class(self.class)
    end

  end
end
