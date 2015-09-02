module Yaks
  class NullResource < Resource
    include attributes.add(collection: false),
            Equalizer.new(:rels, :collection)

    def initialize(opts = {})
      local_opts = {}
      local_opts[:rels]       = opts[:rels]       if opts.key?(:rels)
      local_opts[:collection] = opts[:collection] if opts.key?(:collection)
      super(local_opts)
    end

    def each
      to_enum
    end

    def collection? # rubocop:disable Style/TrivialAccessors
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
