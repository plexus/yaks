module Yaks
  class Mapper
    class Association
      include Equalizer.new(:name, :child_mapper, :rel, :href, :link_if)
      include Util

      attr_reader :name, :child_mapper, :rel, :href, :link_if

      def initialize(options)
        @name          = options.fetch(:name)
        @child_mapper  = options.fetch(:mapper, Undefined)
        @rel           = options.fetch(:rel, Undefined)

        @href          = options.fetch(:href, Undefined)
        @link_if       = options.fetch(:link_if, Undefined)
      end

      def add_to_resource(resource, parent_mapper, context)
        AssociationMapper.new(parent_mapper, self, context).call(resource)
      end

      def render_as_link?(parent_mapper)
        href != Undefined && link_if != Undefined && Resolve(link_if, parent_mapper)
      end

      def map_rel(parent_mapper, policy)
        return rel unless rel.equal?(Undefined)
        policy.derive_rel_from_association(parent_mapper, self)
      end

      # @abstract
      def map_resource(_object, _context)
      end

      # support for HasOne and HasMany
      def resolve_association_mapper(policy)
        return child_mapper unless child_mapper.equal?(Undefined)
        policy.derive_mapper_from_association(self)
      end

    end
  end
end
