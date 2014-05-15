module Yaks
  class Resource
    include Equalizer.new(:links, :attributes, :subresources)
    include Enumerable, LinkLookup

    attr_reader :attributes, :links, :subresources

    def initialize(attributes, links, subresources)
      @attributes   = Yaks::Hash(attributes)
      @links        = Yaks::List(links)
      @subresources = Yaks::Hash(subresources)
    end

    def [](attr)
      attributes[attr]
    end

    def each
      return to_enum unless block_given?
      yield self
    end

    def collection?
      false
    end
  end
end
