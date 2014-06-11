module Yaks
  class Mapper
    class Association
      include Equalizer.new(:name, :mapper, :rel)

      attr_reader :name, :mapper, :rel, :collection_mapper

      def initialize(name, mapper, rel, collection_mapper)
        @name, @mapper, @rel, @collection_mapper =
          name, mapper, rel, collection_mapper
      end

      # @param [#call] lookup
      #   A callable that can retrieve an association by its name
      # @return Array[rel, resource]
      #   Returns the rel (registered type or URI) + the associated, mapped resource
      def create_subresource(parent_mapper, lookup, context)
        [
          map_rel(parent_mapper, context.fetch(:policy)),
          map_resource(lookup[name], context)
        ]
      end

      def map_rel(parent_mapper, policy)
        return @rel unless @rel.equal?(Undefined)
        policy.derive_rel_from_association(parent_mapper, self)
      end

      def association_mapper(policy)
        return @mapper unless @mapper.equal?(Undefined)
        policy.derive_mapper_from_association(self)
      end

      # @abstract
      def map_resource(object, context)
      end

    end
  end
end
