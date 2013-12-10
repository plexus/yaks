module Yaks
  class SerializableAssociation
    include Concord.new(:collection)
    extend Forwardable

    def_delegator :collection, :root_key, :name
    def_delegators :collection, :identity_key, :map, :objects, :empty?

    def identities
      map(&method(:identity))
    end

    def identity(object)
      object[identity_key]
    end
  end
end
