module Yaks
  class Resource
    include Equalizer.new(:links, :attributes, :subresources)

    attr_reader :links, :attributes, :subresources

    def initialize(attributes, links, subresources)
      @links        = Yaks::List(links)
      @attributes   = Yaks::Hash(attributes)
      @subresources = Yaks::Hash(subresources)
    end
  end
end
