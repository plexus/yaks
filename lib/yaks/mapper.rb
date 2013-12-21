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
        nil,
        map_attributes,
        map_links,
        map_subresources
      )
    end

    def map_links
      links.map &σ(:expand_with, μ(:load_attribute))
    end

    def map_attributes
      attributes.map &juxt(ι, μ(:load_attribute))
    end

    def map_subresources
      associations.map do |association|
        [ association.key, association.map_resource(load_association(association.name)) ]
      end
    end

    def load_attribute(name)
      respond_to?(name) ? send(name) : subject.send(name)
    end
    alias load_association load_attribute

  end
end
