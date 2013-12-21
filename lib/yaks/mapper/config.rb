module Yaks
  class Mapper
    class Config
      include Equalizer.new(:attributes)

      def initialize(attributes = Hamster.list, links = Hamster.list, associations = Hamster.list, profile = nil)
        @attributes   = attributes
        @links        = links
        @associations = associations
        @profile      = profile
        freeze
      end

      def new(updates)
        self.class.new(
          updates.fetch(:attributes)   { attributes   },
          updates.fetch(:links)        { links        },
          updates.fetch(:associations) { associations },
          updates.fetch(:profile)      { profile      },
        )
      end

      def attributes(*attrs)
        return @attributes if attrs.empty?
        new(
          attributes: @attributes + attrs.to_list
        )
      end

      def link(rel, template, options = {})
        new(
          links: @links.cons(Link.new(rel, template, options))
        )
      end

      def profile(type = Undefined)
        return @profile if type == Undefined
        new(
          profile: type
        )
      end

      # key
      # embed_style
      # rel
      # (profile)

      def has_one(name, options = {})
        add_association(HasOne, name, options)
      end

      def has_many(name, options = {})
        add_association(HasMany, name, options)
      end

      def add_association(type, name, options = {})
        new(
          associations: @associations.cons(
            type.new(
              name,
              options.fetch(:as) { name },
              options.fetch(:mapper),
              options.fetch(:links) { Yaks::List() },
              options.reject {|k,v| [:as, :mapper, :links].include?(k) }
            )
          )
        )
      end

      def links
        @links
      end

      def associations
        @associations
      end
    end
  end
end
