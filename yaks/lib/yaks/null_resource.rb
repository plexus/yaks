module Yaks
  class NullResource < Resource
    include Equalizer.new(:collection?)

    def initialize(opts = {})
      super()
      @collection = opts.fetch(:collection) { false }
    end

    def each
      to_enum
    end

    def collection?
      @collection
    end

    def null_resource?
      true
    end

    def update_attributes(_new_attrs)
      raise UnsupportedOperationError, "Operation #{__method__} not supported on #{self.class}"
    end

    def add_link(_link)
      raise UnsupportedOperationError, "Operation #{__method__} not supported on #{self.class}"
    end

    def add_control(_control)
      raise UnsupportedOperationError, "Operation #{__method__} not supported on #{self.class}"
    end

    def add_subresource(_rel, _subresource)
      raise UnsupportedOperationError, "Operation #{__method__} not supported on #{self.class}"
    end
  end
end
