module Yaks
  class Resource
    include Equalizer.new(:links, :attributes, :subresources)

    attr_reader :links, :attributes, :subresources

    def initialize(attributes, links, subresources)
      @links        = Yaks::List(links)
      @attributes   = Yaks::Hash(attributes)
      @subresources = Yaks::Hash(subresources)
    end

    def uri
      self_link = links_by_rel(:self).first
      self_link.uri if self_link
    end

    def links_by_rel(rel)
      links.select {|link| link.rel == rel}
    end

    def [](attr)
      attributes[attr]
    end

  end
end
