# -*- coding: utf-8 -*-

module Yaks
  class CollectionMapper < Mapper
    attr_reader :collection, :resource_mapper
    alias collection subject

    def initialize(collection, resource_mapper, policy)
      super(collection, policy)
      @resource_mapper = resource_mapper
    end

    def to_resource
      CollectionResource.new(
        type: resource_mapper.config.type || policy.derive_type_from_mapper_class(resource_mapper),
        links: map_links,
        attributes: map_attributes,
        members: collection.map {|obj| resource_mapper.new(obj, policy).to_resource }
      )
    end

  end
end
