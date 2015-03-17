module Yaks
  class Mapper
    class Form
      class DynamicField
        include Attributes.new(:block)

        def self.create(_opts = nil, &block)
          new(block: block)
        end

        def to_resource_fields(mapper)
          Config.build_with_object(mapper.object, &block).to_resource_fields(mapper)
        end
      end
    end
  end
end
