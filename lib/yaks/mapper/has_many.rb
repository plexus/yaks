module Yaks
  class Mapper
    class HasMany < Association
      def map_resource(collection, context)
        resource_mapper = association_mapper(context.fetch(:policy))
        context         = context.merge(resource_mapper: resource_mapper)
        collection_mapper.new(collection, context).to_resource
      end

      def collection_mapper
        return @collection_mapper unless @collection_mapper.equal? Undefined
        CollectionMapper
      end
    end
  end
end
