module Yaks
  class Serializer
    extend ClassMethods

    attr_accessor :object
    attr_reader :serializer_lookup

    def initialize(serializer_lookup = Yaks.default_serializer_lookup)
      @serializer_lookup = serializer_lookup
    end

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
      return Hamster::EmptyList if self.class._associations.nil?

      Hamster.enumerate(self.class._associations.each).map do |type, name|
        if type == :has_one
          obj        = send(name)
          serializer = serializer_lookup.(obj).new
          objects    = Hamster.list(serializer.serializable_object(obj))
        else
          serializer = nil
          objects = Hamster.enumerate(send(name).each).map do |obj|
            serializer ||= serializer_lookup.(obj).new
            serializer.serializable_object(obj)
          end
        end
        SerializableAssociation.new( SerializableCollection.new(name, :id, objects) )
      end
    end
  end
end
