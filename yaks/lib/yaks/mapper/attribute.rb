module Yaks
  class Mapper
    class Attribute
      include Attribs.new(:name, :block)
      include Util

      def self.create(name, _options = nil, &block)
        new(name: name, block: block)
      end

      def add_to_resource(resource, mapper, _context)
        if block
          attribute = Resolve(block, mapper)
        else
          attribute = mapper.load_attribute(name)
        end
        resource.merge_attributes(name => attribute)
      end
    end
  end
end
