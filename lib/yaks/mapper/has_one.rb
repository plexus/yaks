module Yaks
  class Mapper
    class HasOne < Association
      def map_resource(object, context)
        resolve_association_mapper(context.fetch(:policy))
          .new(context)
          .call(object)
      end

      def singular_name
        name.to_s
      end
    end
  end
end
