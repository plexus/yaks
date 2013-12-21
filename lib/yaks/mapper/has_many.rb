module Yaks
  class Mapper
    class HasMany < Association
      def map_resource(collection)
        CollectionMapper.new(collection, mapper).to_resource
      end
    end
  end
end
