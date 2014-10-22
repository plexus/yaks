module Yaks
  class Mapper
    class Control
      include Attributes.new(
                name: nil, href: nil, title: nil, method: nil, media_type: nil, fields: []
              ),
              Configurable

      def self.create(name = nil, options = {})
        new({name: name}.merge(options))
      end

      class Field
        include Attributes.new(:name)

        def self.create(name)
          new name: name
        end
      end

      config_method :field, create: Field, append_to: :fields
    end
  end
end
