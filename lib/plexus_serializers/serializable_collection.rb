module PlexusSerializers
  class SerializableCollection
    include Concord.new(:root_key, :identity_key, :objects)
    extend Forwardable

    public :root_key, :identity_key

    def_delegators :objects, :map, :flat_map, :empty?
  end
end
