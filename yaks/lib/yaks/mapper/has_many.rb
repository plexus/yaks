module Yaks
  class Mapper
    class HasMany < Association
      include Util,
              attributes.add(collection_mapper: Undefined)

      def map_resource(collection, context)
        return NullResource.new(collection: true) if collection.nil?
        policy      = context.fetch(:policy)
        item_mapper = resolve_association_mapper(policy)
        context     = context.merge(item_mapper: item_mapper)
        collection_mapper(collection, policy).new(context).call(collection)
      end

      def collection_mapper(collection = nil, policy = nil)
        return @collection_mapper unless @collection_mapper.equal? Undefined
        policy.derive_mapper_from_object(collection) if policy && collection
      end

      def singular_name
        singularize(name.to_s)
      end
    end
  end
end
