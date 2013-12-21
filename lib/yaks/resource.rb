module Yaks
  class Resource
    include Equalizer.new(:uri, :links, :attributes, :subresources)

    attr_reader :uri, :links, :attributes, :subresources

    def initialize(uri, attributes, links, subresources)
      @uri          = uri
      @links        = Yaks::List(links)
      @attributes   = Yaks::Hash(attributes)
      @subresources = Yaks::Hash(subresources)
    end

    def links_by_rel(rel)
      links.select {|link| link.rel == rel}
    end

    def [](attr)
      attributes[attr]
    end

  end
end
