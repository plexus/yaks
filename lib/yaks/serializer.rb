module Yaks
  class Serializer
    include Yaks
    extend ClassMethods

    attr_accessor :object
    attr_reader :serializer_lookup, :root_key

    def initialize(options = {})
      @serializer_lookup = options.fetch(:serializer_lookup) { Yaks.default_serializer_lookup }
      @root_key = options.fetch(:root_key) { self.class._root_key }
    end

    def identity_key
      self.class._identity_key
    end

    def attributes
      self.class._attributes
    end

    def associations
      self.class._associations
    end

    def filter(attributes)
      attributes
    end

    def serializable_collection(enumerable)
      SerializableCollection.new(root_key, identity_key, enumerable.map(&method(:serializable_object)))
    end

    def serializable_object(object)
      self.object = object
      SerializableObject.new(
        serializable_attributes(object),
        serializable_associations(object)
      )
    end

    def serializable_attributes(object)
      Hash(filter(attributes).map {|attr| [attr, send(attr)] })
    end

    def serializable_associations(object)
      Hamster.enumerate(filter(associations.map(&:last)).each).map do |name|
        type = associations.detect {|type, n| name == n }.first
        if type == :has_one
          obj        = send(name)
          serializer = serializer_lookup.(obj).new
          objects    = List(serializer.serializable_object(obj))
        else
          serializer = nil
          objects = Hamster.enumerate(send(name).each).map do |obj|
            serializer ||= serializer_lookup.(obj).new
            serializer.serializable_object(obj)
          end
        end
        SerializableAssociation.new( SerializableCollection.new(name, :id, objects), type == :has_one )
      end
    end
  end
end
