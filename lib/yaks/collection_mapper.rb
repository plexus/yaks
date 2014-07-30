# -*- coding: utf-8 -*-

module Yaks
  class CollectionMapper < Mapper
    alias collection object

    # @param [Array] collection
    # @return [Array]
    def call(collection)
      @object = collection

      attrs = {
        type: collection_type,
        members: collection().map do |obj|
          mapper_for_model(obj).new(context).call(obj)
        end
      }

      attrs[ :collection_rel ] = collection_rel

      map_attributes(
        map_links(
          CollectionResource.new(attrs)
        )
      )
    end

    private

    def collection_rel
      if collection_type
        policy.expand_rel( pluralize( collection_type ) )
      else
        'collection'
      end
    end

    def collection_type
      if item_mapper = context[:item_mapper]
        item_mapper.config.type || policy.derive_type_from_mapper_class(item_mapper)
      end
    end

    def mapper_for_model(model)
      context.fetch(:item_mapper) do
        policy.derive_mapper_from_object(model)
      end
    end
  end
end
