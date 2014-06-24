module Yaks
  class NullResource
    include Equalizer.new(:collection?)
    include Enumerable

    def initialize(opts = {})
      @collection = opts.fetch(:collection) { false }
    end

    def each
      to_enum
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

    def null_resource?
      true
    end
  end
end
