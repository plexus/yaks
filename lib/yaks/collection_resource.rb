module Yaks
  class CollectionResource
    include Equalizer.new(:links, :members)
    include Enumerable, Resource::LinkLookup

    extend Forwardable

    attr_reader :links, :members

    def_delegators :members, :each

    def initialize(links, members)
      @links   = Yaks::List(links)
      @members = Yaks::List(members)
    end

    def attributes
      Yaks::Hash()
    end

    def []
    end

    def collection?
      true
    end

  end
end
