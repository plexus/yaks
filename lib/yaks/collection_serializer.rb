module Yaks
  class CollectionSerializer < Serializer
    alias :collection :object

    def resource_collection
      if collection.empty?
        ResourceCollection::EmptyCollection
      else
        serializer_class = serializer_class_for(collection.first)
        ResourceCollection.new(
          serializer_class._root_key,
          serializer_class._identity_key,
          collection.map do |object|
            serializer_class.new(object, options).resource
          end
        )
      end
    end

    def self.call(objects, options = {})
      new(objects, options).resource_collection
    end

  end
end
