module Yaks
  class Mapper
    class Attribute
      include Attributes.new(:name)

      def initialize(name)
        @name = name
      end

      def add_to_resource(resource, mapper, _context)
        resource.merge_attributes(name => mapper.load_attribute(name))
      end
    end
  end
end
