module Yaks
  class Mapper
    class Config
      include Attributes.new(
                type: nil, attributes: [], links: [], associations: [], controls: []
              ),
              Configurable

      def type(type = Undefined)
        return @type if type.equal?(Undefined)
        update(type: type)
      end

      def attributes(*attrs)
        return @attributes if attrs.empty?
        append_to(:attributes, *attrs.map(&Attribute.method(:new)))
      end

      config_method :link,      create: Link,                    append_to: :links
      config_method :has_one,   create: HasOne,                  append_to: :associations
      config_method :has_many,  create: HasMany,                 append_to: :associations
      config_method :attribute, create: Attribute,               append_to: :attributes
      config_method :attribute, create: Attribute,               append_to: :attributes
      config_method :control,
                    append_to: :controls,
                    create: StatefulBuilder.new(
                      Control,
                      Control.anima.attribute_names +
                        HTML5Forms::INPUT_TYPES +
                        [:field]
                    )
    end
  end
end
