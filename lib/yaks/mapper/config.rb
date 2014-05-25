module Yaks
  class Mapper
    class Config
      include Equalizer.new(:name, :attributes, :links, :associations)

      attr_reader :links, :associations

      def initialize(name, attributes, links, associations)
        @name         = name
        @attributes   = attributes
        @links        = links
        @associations = associations
      end

      def updated(updates)
        self.class.new(
          updates.fetch(:name)         { name         },
          updates.fetch(:attributes)   { attributes   },
          updates.fetch(:links)        { links        },
          updates.fetch(:associations) { associations }
        )
      end

      def name(name = Undefined)
        return @name if name.equal?(Undefined)
        updated(name: name)
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
