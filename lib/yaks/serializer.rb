module Yaks
  class Serializer
    include Util, Lookup
    extend ClassMethods

    attr_reader :serializer_lookup, :root_key, :object, :options

    def initialize(object, options = {})
      @object            = object
      @serializer_lookup = options.fetch(:serializer_lookup) { Yaks.default_serializer_lookup }
      @root_key          = options.fetch(:root_key) { self.class._root_key }
      @options           = options
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

    def serializable_object
      SerializableObject.new(
        serializable_attributes,
        serializable_associations
      )
    end

    def serializable_attributes
      Hash(filter(attributes).map {|attr| [attr, send(attr)] })
    end

    def serializable_associations
      Hamster.enumerate(filter(associations.map(&:last)).each).map do |name|
        type = associations.detect {|type, n| name == n }.first
        if type == :has_one
          obj        = send(name)
          objects    = List(serializer_for(obj).serializable_object)
        else
          objects = Hamster.enumerate(send(name).each).map do |obj|
            serializer_for(obj).serializable_object
          end
        end
        SerializableAssociation.new( SerializableCollection.new(name, :id, objects), type == :has_one )
      end
    end
  end
end
