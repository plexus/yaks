module Yaks
  class Serializer
    extend ClassMethods

    attr_accessor :object

    def serialize_collection(enumerable)
      SerializableCollection.new(root_key, identity_key, enumerable.map(&method(:serializable_object)))
    end

    def root_key
      self.class._root_key
    end

    def identity_key
      self.class._identity_key
    end

    def serializable_object(object)
      self.object = object
      SerializableObject.new(attributes(object), associations(object))
    end

    def attributes(object)
      Hamster.hash(
        self.class._attributes.map do |attr|
          [attr, send(attr)]
        end
      )
    end

    def associations(object)
      Hamster.enumerate(self.class._associations).map do |type, name|
        if type == :has_one
          obj = send(name)
          serializer = serializer_lookup(obj).new
          objects    = Hamster.list(serializer.serializable_object(obj))
        else
          serializer = nil
          objects = Hamster.enumerate(send(name)).map do |obj|
            serializer ||= serializer_lookup(obj).new
            serializer.serializable_object(obj)
          end
        end
        SerializableAssociation.new( SerializableCollection.new(name, :id, objects) )
      end
    end
  end
end
