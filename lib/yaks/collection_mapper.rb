# -*- coding: utf-8 -*-

module Yaks
  class CollectionMapper < Mapper
    attr_reader :collection
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

      CollectionResource.new(
        type: collection_type,
        members_rel: members_rel,
        links: map_links,
        attributes: map_attributes,
        members: collection.map do |obj|
          mapper_for_model(obj).new(context).call(obj)
        end
      )
    end

    private

    def members_rel
      policy.expand_rel( 'collection', pluralize( collection_type ) )
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
