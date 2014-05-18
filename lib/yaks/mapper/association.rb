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
      # @param [Hash] options
      # @return Array[rel, resource]
      #   Returns the rel (registered type or URI) + the associated, mapped resource
      def map_to_resource_pair(parent_mapper, lookup, policy)
        [
          map_rel(parent_mapper, policy),
          map_resource(lookup[name], policy)
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

    end
  end
end
