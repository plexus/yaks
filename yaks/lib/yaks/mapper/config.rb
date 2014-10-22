module Yaks
  class Mapper
    class Config
      include Anima.new(:type, :attributes, :links, :associations),
              Anima::Update,
              AttributeDefaults.new(type: nil, attributes: [], links: [], associations: [])

      def type(type = Undefined)
        return @type if type.equal?(Undefined)
        update(type: type)
      end

      def attributes(*attrs)
        return @attributes if attrs.empty?
        update(attributes: @attributes + attrs.map(&Attribute.method(:new)))
      end

      def link(rel, template, options = {})
        update(links: @links + [Link.new(rel, template, options)])
      end

      def add_association(type, name, options)
        update(associations: @associations + [type.new(options.merge(name: name))])
      end

      def has_one(name, options = {})
        add_association(HasOne, name, options)
      end

      def has_many(name, options = {})
        add_association(HasMany, name, options)
      end

    end
  end
end
