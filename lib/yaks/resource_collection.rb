module Yaks
  class ResourceCollection
    include Concord.new(:root_key, :identity_key, :objects)
    extend Forwardable

    public :root_key, :identity_key

    def_delegators :objects, :map, :flat_map, :empty?, :count

    EmptyCollection = new(Undefined, Undefined, [])
  end
end
