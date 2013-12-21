module Yaks
  class Mapper
    class HasMany < Association
      def map_resource(collection)
        self_link
        CollectionResource.new(nil, collection.map {|obj| mapper.new(obj).to_resource})
      end
    end
  end
end
