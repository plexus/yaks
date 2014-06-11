# -*- coding: utf-8 -*-

module Yaks
  class CollectionMapper < Mapper
    attr_reader :collection
    alias collection object

    def initialize(collection, context)
      super(collection, context)
    end

    def resource_mapper
      context[:resource_mapper]
    end

    def to_resource
      CollectionResource.new(
        type: collection_type,
        links: map_links,
        attributes: map_attributes,
        members: collection.map do |obj|
          mapper_for_model(obj).new(obj, context).to_resource
        end
      )
    end

    private

    def collection_type
      return unless context.key?(:resource_mapper)
      resource_mapper.config.type || policy.derive_type_from_mapper_class(resource_mapper)
    end

    def mapper_for_model(model)
      context.fetch(:resource_mapper) do
        policy.derive_mapper_from_object(model)
      end
    end
  end
end
