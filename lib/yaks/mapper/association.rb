module Yaks
  class Mapper
    class Association
      include Equalizer.new(:name, :mapper)
      attr_reader :name, :mapper

      def initialize(name, mapper)
        @name   = name
        @mapper = mapper
      end

    end

    class HasOne < Association
      def map_resource(instance)
        mapper.new(instance).to_resource
      end
    end

    class HasMany < Association
    end
  end
end
