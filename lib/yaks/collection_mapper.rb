# -*- coding: utf-8 -*-

module Yaks
  class CollectionMapper < Mapper
    alias collection object

    def initialize(context)
      super(context)
    end

    def member_mapper
      context.fetch(:member_mapper) do
        if collection.first
          mapper_for_model(collection.first)
        end
      end
    end

    def call(collection)
      @object = collection

      attrs = {
        type: collection_type,
        members: collection().map do |obj|
          mapper_for_model(obj).new(context).call(obj)
        end
      }

      attrs[ :members_rel ] = members_rel if members_rel

      map_attributes(
        map_links(
          CollectionResource.new(attrs)
        )
      )
    end

    private

    def members_rel
      policy.expand_rel( 'collection', pluralize( collection_type ) ) if collection_type
    end

    def collection_type
      return unless member_mapper
      member_mapper.config.type || policy.derive_type_from_mapper_class(member_mapper)
    end

    def mapper_for_model(model)
      context.fetch(:member_mapper) do
        policy.derive_mapper_from_object(model)
      end
    end
  end
end
