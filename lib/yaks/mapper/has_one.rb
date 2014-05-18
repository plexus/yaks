module Yaks
  class Mapper
    class HasOne < Association
      def map_resource(instance, policy)
        association_mapper(policy).new(instance, policy).to_resource
      end
    end
  end
end
