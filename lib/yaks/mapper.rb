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

    def call(object)
      @object = object

      return NullResource.new if object.nil?

      Resource.new(
        type:         mapper_name,
        attributes:   map_attributes,
        links:        map_links,
        subresources: map_subresources
      )
    end

    def map_attributes
      filter(attributes).each_with_object({}) do |attr, memo|
        memo[attr] = load_attribute(attr)
      end
    end

    def map_links
      links.map &send_with_args(:map_to_resource_link, self)
    end

    def map_subresources
      attributes   = filter(associations.map(&:name))
      associations = associations().select{|assoc| attributes.include? assoc.name }
      associations.each_with_object({}) do |association, memo|
        rel, subresource = association.create_subresource(
          self,
          method(:load_association),
          context
        )
        memo[rel] = subresource
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
