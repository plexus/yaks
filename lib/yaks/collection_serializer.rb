module Yaks
  class CollectionSerializer < Serializer
    alias :collection :object

    def serializable_collection
      if collection.empty?
        SerializableCollection::EmptyCollection
      else
        serializer_class = serializer_class_for(collection.first)
        SerializableCollection.new(
          serializer_class._root_key,
          serializer_class._identity_key,
          collection.map do |object|
            serializer_class.new(object, options).serializable_object
          end
        )
      end
    end

    def self.call(objects, options = {})
      new(objects, options).serializable_collection
    end

  end
end
