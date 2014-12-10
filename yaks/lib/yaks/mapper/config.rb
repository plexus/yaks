module Yaks
  class Mapper
    class Config
      include Attributes.new(
                type: nil, attributes: [], links: [], associations: [], forms: []
              )

      def add_attributes(*attrs)
        append_to(:attributes, *attrs.map(&Attribute.method(:new)))
      end
    end
  end
end
