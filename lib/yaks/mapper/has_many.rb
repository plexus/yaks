module Yaks
  class Mapper
    class HasMany < Association
      def map_resource(collection, opts)
        opts = opts.merge(options)
        collection_mapper(opts).new(collection, mapper(opts), opts).to_resource
      end

      def collection_mapper(opts)
        opts = opts.merge(options)
        opts.fetch(:collection_mapper) { CollectionMapper }
      end
    end
  end
end
