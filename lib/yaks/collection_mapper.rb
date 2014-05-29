# -*- coding: utf-8 -*-

module Yaks
  class CollectionMapper < Mapper
    attr_reader :collection, :resource_mapper
    alias collection subject

    def initialize(collection, resource_mapper = Undefined, policy)
      super(collection, policy)
      @resource_mapper = resource_mapper
    end

    def to_resource
      CollectionResource.new(
        type: collection_type,
        links: map_links,
        attributes: map_attributes,
        members: collection.map do |obj|
          mapper_for_model(obj).new(obj, policy).to_resource
        end
      )
    end

    private

    def collection_type
      return if resource_mapper.equal? Undefined
      resource_mapper.config.type || policy.derive_type_from_mapper_class(resource_mapper)
    end

    def mapper_for_model(model)
      return resource_mapper unless resource_mapper.equal? Undefined
      policy.derive_mapper_from_model(model)
    end
  end
end
