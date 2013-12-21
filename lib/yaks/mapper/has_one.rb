module Yaks
  class Mapper
    class HasOne < Association
      def map_resource(instance, opts)
        opts = opts.merge(options)
        mapper(opts).new(instance, opts).to_resource
      end
    end
  end
end
