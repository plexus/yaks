module Yaks
  class Mapper
    class Attribute
      include Attribs.new(:name)

      def initialize(name)
        super(name: name)
      end

      def add_to_resource(resource, mapper, _context)
        resource.merge_attributes(name => mapper.load_attribute(name))
      end
    end
  end
end
