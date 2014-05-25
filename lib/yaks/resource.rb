module Yaks
  class Resource
    include Equalizer.new(:type, :links, :attributes, :subresources)
    include Enumerable

    attr_reader :type, :attributes, :links, :subresources

    def initialize(options)
      @type         = options.fetch(:type, nil)
      @attributes   = options.fetch(:attributes, {})
      @links        = options.fetch(:links, [])
      @subresources = options.fetch(:subresources, {})
    end

    def [](attr)
      attributes[attr]
    end

    # def type
    # end

    def each
      return to_enum unless block_given?
      yield self
    end

    def collection?
      false
    end

  end
end
