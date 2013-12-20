# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    extend ClassMethods, Forwardable
    include Concord.new(:subject)
    include Util

    def_delegators 'self.class', :config
    def_delegators :config, :attributes, :links, :associations

    def to_resource
      Resource.new(
        map_attributes,
        map_links,
        map_subresources
      )
    end

    def map_links
      links.map do |link|
        link.expand_to_resource_link(
          link.variables.map.with_object({}) do |var, hsh|
            hsh[var]=load_attribute(var)
          end
        )
      end
    end

    def map_attributes
      attributes.map &juxt(ι, μ(:load_attribute))
    end

    def map_subresources
      associations.map do |association|
        name = association.name
        [ name, association.map_resource(load_association(name)) ]
      end
    end

    def load_attribute(name)
      respond_to?(name) ? send(name) : subject.send(name)
    end
    alias load_association load_attribute

  end
end
