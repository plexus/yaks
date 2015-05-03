module Yaks
  class NullResource < Resource
    include attributes.add(collection: false),
            Equalizer.new(:rels, :collection)

    def initialize(opts = {})
      _opts = {}
      _opts[:rels]       = opts[:rels]       if opts.key?(:rels)
      _opts[:collection] = opts[:collection] if opts.key?(:collection)
      super(_opts)
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

    def seq
      []
    end

    def map
      return [] if collection?
      raise UnsupportedOperationError, "Operation #{__method__} not supported on #{self.class}"
    end

    def merge_attributes(_new_attrs)
      raise UnsupportedOperationError, "Operation #{__method__} not supported on #{self.class}"
    end

    def add_link(_link)
      raise UnsupportedOperationError, "Operation #{__method__} not supported on #{self.class}"
    end

    def add_form(_form)
      raise UnsupportedOperationError, "Operation #{__method__} not supported on #{self.class}"
    end

    def add_subresource(_subresource)
      raise UnsupportedOperationError, "Operation #{__method__} not supported on #{self.class}"
    end
  end
end
