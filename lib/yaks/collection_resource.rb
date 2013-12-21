module Yaks
  class CollectionResource
    include Equalizer.new(:uri, :links, :members)

    attr_reader :uri, :links, :members

    def initialize(uri, members)
      @uri     = uri
      @members = Yaks::List(members)
    end
  end
end
