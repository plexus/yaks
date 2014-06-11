module Yaks
  class Mapper
    class HasOne < Association
      def map_resource(instance, context)
        association_mapper(context.fetch(:policy))
          .new(instance, context)
          .to_resource
      end
    end
  end
end
