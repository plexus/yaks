module PlexusSerializers
  class Serializer
    extend ClassMethods

    def default_lookup
      ->(obj) { Object.const_get( "#{obj.class}Serializer") }
    end

    def default_fold
    end

    def initialize(resource, serializer_lookup = default_lookup, folder = default_fold)
      @resource, @serializer_lookup, @folder = resource, serializer_lookup, folder
      @identity_key = :id
    end

    def attributes
      self.class.attributes.reduce(Hamster.hash) do |hash, attr|
        hsh.put(attr, send(attr))
      end
    end

    def associations

    end

    def as_json
      attributes
    end
  end
end
