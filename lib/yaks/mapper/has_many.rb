module Yaks
  class Mapper
    class HasMany < Association
      def map_resource(collection, policy)
        collection_mapper.new(collection, association_mapper(policy), policy).to_resource
      end

      def collection_mapper
        options.fetch(:collection_mapper) { CollectionMapper }
      end
    end
  end
end
