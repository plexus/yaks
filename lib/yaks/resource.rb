module Yaks
  class Resource
    include Equalizer.new(:links, :attributes, :subresources)
    include Enumerable

    attr_reader :links, :attributes, :subresources

    def initialize(attributes, links, subresources)
      @attributes   = Yaks::Hash(attributes)
      @links        = Yaks::List(links)
      @subresources = Yaks::Hash(subresources)
    end

    def uri
      self_link = links_by_rel(:self).first
      self_link.uri if self_link
    end

    def profile
      link = links_by_rel(:profile).first
      link.uri if link
    end

    def links_by_rel(rel)
      links.select {|link| link.rel == rel}
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
