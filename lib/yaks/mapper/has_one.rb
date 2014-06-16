module Yaks
  class Mapper
    class HasOne < Association
      def map_resource(object, context)
        association_mapper(context.fetch(:policy))
          .new(context)
          .call(object)
      end
    end
  end
end
