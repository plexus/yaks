module Yaks
  class Mapper
    class HasOne < Association
      def map_resource(instance)
        mapper.new(instance).to_resource
      end
    end
  end
end
