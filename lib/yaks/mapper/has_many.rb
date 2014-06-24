module Yaks
  class Mapper
    class HasMany < Association
      include Util

      def initialize(options)
        super
        @collection_mapper = options.fetch(:collection_mapper, Undefined)
      end

      def map_resource(collection, context)
        return NullResource.new(collection: true) if collection.nil?
        policy        = context.fetch(:policy)
        member_mapper = association_mapper(policy)
        context       = context.merge(member_mapper: member_mapper)
        collection_mapper(collection, policy).new(context).call(collection)
      end

      def collection_mapper(collection, policy)
        return @collection_mapper unless @collection_mapper.equal? Undefined
        policy.derive_mapper_from_object(collection)
      end

      def singular_name
        singularize(name.to_s)
      end
    end
  end
end
