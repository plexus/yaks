module Yaks
  class Mapper
    class HasMany < Association
      def map_resource(collection)
        collection_mapper.new(collection, mapper).to_resource
      end

      def collection_mapper
        options[:collection_mapper] || CollectionMapper
      end
    end
  end
end
