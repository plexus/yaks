module Yaks
  class NullResource
    include Enumerable

    def initialize(opts = {})
      @collection = opts.fetch(:collection, false)
    end

    def each
      return to_enum unless block_given?
    end

    def attributes
      {}
    end

    def links
      []
    end

    def subresources
      {}
    end

    def [](*)
    end

    def type
    end

    def collection?
      @collection
    end
  end
end
