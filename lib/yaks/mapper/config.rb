module Yaks
  class Mapper
    class Config
      include Equalizer.new(:attributes, :links, :associations)

      attr_reader :links, :associations, :key_name

      def initialize(key_name, attributes, links, associations)
        @key_name     = key_name
        @attributes   = Yaks::List(attributes)
        @links        = Yaks::List(links)
        @associations = Yaks::List(associations)
      end

      def updated(updates)
        self.class.new(
          updates.fetch(:key_name)     { key_name     },
          updates.fetch(:attributes)   { attributes   },
          updates.fetch(:links)        { links        },
          updates.fetch(:associations) { associations }
        )
      end

      def key(key)
        updated(key_name: key)
      end

      def attributes(*attrs)
        return @attributes if attrs.empty?
        updated(
          attributes: @attributes + attrs.to_list
        )
      end

      def link(rel, template, options = {})
        updated(
          links: @links.cons(Link.new(rel, template, options))
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
          associations: @associations.cons(
            type.new(
              name,
              options.fetch(:mapper)            { Undefined },
              options.fetch(:rel)               { Undefined },
              options.fetch(:collection_mapper) { Undefined },
            )
          )
        )
      end
    end
  end
end
