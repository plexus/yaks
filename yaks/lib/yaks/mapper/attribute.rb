module Yaks
  class Mapper
    class Attribute
      include Equalizer.new(:name)

      attr_reader :name

      def initialize(name)
        @name = name
      end

      def add_to_resource(resource, mapper, _context)
        resource.update_attributes(name => mapper.load_attribute(name))
      end
    end
  end
end
