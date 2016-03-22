module Yaks
  class Mapper
    class Attribute
      extend Forwardable, Util
      include Attribs.new(:name, :block, if: true), Util

      def self.create(name, options = {}, &block)
        new(options.merge(name: name, block: block))
      end

      def add_to_resource(resource, mapper, _context)
        return resource unless Resolve(self.if, mapper)

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
