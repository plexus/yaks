module Yaks
  class Mapper
    class Config
      include Equalizer.new(:type, :attributes, :links, :associations)

      attr_reader :links, :associations

      def initialize(type, attributes, links, associations)
        @type         = type
        @attributes   = attributes
        @links        = links
        @associations = associations
      end

      def updated(updates)
        self.class.new(
          updates.fetch(:type)         { type         },
          updates.fetch(:attributes)   { attributes   },
          updates.fetch(:links)        { links        },
          updates.fetch(:associations) { associations }
        )
      end

      def type(type = Undefined)
        return @type if type.equal?(Undefined)
        updated(type: type)
      end

      def attributes(*attrs)
        return @attributes if attrs.empty?
        updated(
          attributes: @attributes + attrs
        )
      end

      def link(rel, template, options = {})
        updated(
          links: @links + [Link.new(rel, template, options)]
        )
      end

      def has_one(name, options = {})
        add_association(HasOne, name, options)
      end

      def has_many(name, options = {})
        add_association(HasMany, name, options)
      end

      def add_association(type, name, options)
        updated(
          associations: @associations + [
            type.new(
              name,
              options.fetch(:mapper)            { Undefined },
              options.fetch(:rel)               { Undefined },
              options.fetch(:collection_mapper) { Undefined },
            )
          ]
        )
      end
    end
  end
end
