module Yaks
  class CollectionResource
    include Equalizer.new(:uri, :links, :members)
    include Enumerable
    extend Forwardable

    attr_reader :uri, :links, :members

    def_delegators :members, :each

    def initialize(uri, members)
      @uri     = uri
      @members = Yaks::List(members)
    end

    def collection?
      true
    end

  end
end
