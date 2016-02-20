module Yaks
  class Mapper
    class Attribute
      extend Forwardable, Util
      include Util
      include Attribs.new(:name, :block, options: {}.freeze)

      def self.create(*args, &block)
        args, options = extract_options(args)
        new(name: args.first, options: options, block: block)
      end

      def add_to_resource(resource, mapper, _context)
        return unless mapper.expand_value(options.fetch(:if, true))

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
