module Yaks
  class Mapper
    class HasMany < Association
      def map_resource(collection, context)
        policy        = context.fetch(:policy)
        member_mapper = association_mapper(policy)
        context       = context.merge(member_mapper: member_mapper)
        collection_mapper(collection, policy).new(context).call(collection)
      end

      def collection_mapper(collection, policy)
        return @collection_mapper unless @collection_mapper.equal? Undefined
        policy.derive_mapper_from_object(collection)
      end
    end
  end
end
