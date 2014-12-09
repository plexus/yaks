module Yaks
  class Mapper
    class Config
      extend DSL

      include Attributes.new(
                type: nil, attributes: [], links: [], associations: [], forms: []
              )

      def type(type = Undefined) # TODO s/type/tag/
        return @type if type.equal?(Undefined)
        with(type: type)
      end

      def attributes(*attrs)
        return @attributes if attrs.empty?
        append_to(:attributes, *attrs.map(&Attribute.method(:new)))
      end

      dsl_method :link,      create: Link,      append_to: :links
      dsl_method :has_one,   create: HasOne,    append_to: :associations
      dsl_method :has_many,  create: HasMany,   append_to: :associations
      dsl_method :attribute, create: Attribute, append_to: :attributes
      dsl_method :form,      create: Form,      append_to: :forms
    end
  end
end
