module Yaks
  class Mapper
    class Association
      include Equalizer.new(:name, :mapper, :rel)

      attr_reader :name, :mapper, :rel

      def initialize(options)
        @name = options.fetch(:name)
        @mapper = options.fetch(:mapper, Undefined)
        @rel = options.fetch(:rel, Undefined)
      end

      def add_to_resource(resource, parent_mapper, lookup, context)
        resource.add_subresource(
          map_rel(parent_mapper, context.fetch(:policy)),
          map_resource(lookup[name], context)
        )
      end

      def map_rel(parent_mapper, policy)
        return @rel unless @rel.equal?(Undefined)
        policy.derive_rel_from_association(parent_mapper, self)
      end

      # @abstract
      def map_resource(object, context)
      end

      def association_mapper(policy)
        return @mapper unless @mapper.equal?(Undefined)
        policy.derive_mapper_from_association(self)
      end

    end
  end
end
