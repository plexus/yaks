module Yaks
  class Mapper
    class Association
      include Equalizer.new(:name, :mapper, :rel)

      attr_reader :name, :mapper, :rel

      def initialize(options)
        @name   = options.fetch(:name)
        @mapper = options.fetch(:mapper, Undefined)
        @rel    = options.fetch(:rel, Undefined)
      end

      def add_to_resource(resource, mapper, context)
        mapper_stack = context[:mapper_stack] + [mapper]
        context      = context.merge(mapper_stack: mapper_stack)
        policy       = context.fetch(:policy)

        rel         = map_rel(mapper, policy)
        subresource = map_resource(mapper.load_association(name), context)

        resource.add_subresource(rel, subresource)
      end

      def map_rel(mapper, policy)
        return @rel unless @rel.equal?(Undefined)
        policy.derive_rel_from_association(mapper, self)
      end

      # @abstract
      def map_resource(_object, _context)
      end

      def association_mapper(policy)
        return @mapper unless @mapper.equal?(Undefined)
        policy.derive_mapper_from_association(self)
      end

    end
  end
end
