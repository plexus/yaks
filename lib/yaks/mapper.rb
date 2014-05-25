# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    extend ClassMethods, Forwardable
    include Util, FP

    def_delegators 'self.class', :config
    def_delegators :config, :attributes, :links, :associations

    attr_reader :subject, :policy
    private :subject
    alias object subject

    def initialize(subject, policy)
      @subject = subject
      @policy  = policy
    end

    def to_resource
      return NullResource.new if subject.nil?

      Resource.new(
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
        rel, subresource = association.map_to_resource_pair(
          self,
          method(:load_association),
          policy
        )
        memo[rel] = subresource
      end
    end

    def load_attribute(name)
      respond_to?(name) ? public_send(name) : subject.public_send(name)
    end
    alias load_association load_attribute

    def filter(attrs)
      attrs
    end

    def mapper_name
      config.name || policy.derive_key_from_mapper(self)
    end

  end
end
