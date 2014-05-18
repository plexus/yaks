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
        map_attributes,
        map_links,
        map_subresources
      )
    end

    def map_attributes
      filter(attributes).map &juxt(identity_function, method(:load_attribute))
    end

    def map_links
      links.map &send_with_args(:map_to_resource_link, self)
    end

    def map_subresources
      attributes = filter(associations.map(&:name))
      associations.select{|assoc| attributes.include? assoc.name }.map do |association|
        association.map_to_resource_pair(
          self,
          method(:load_association),
          policy
        )
      end
    end

    def load_attribute(name)
      respond_to?(name) ? public_send(name) : subject.public_send(name)
    end
    alias load_association load_attribute

    def filter(attrs)
      attrs
    end

  end
end
