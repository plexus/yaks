module Yaks
  class Mapper
    class Association
      include Equalizer.new(:name, :mapper, :links)
      include SharedOptions

      attr_reader :name, :key, :mapper, :links, :options
      private :links, :options

      def initialize(name, key, mapper, links, options)
        @name    = name
        @key     = key
        @mapper  = mapper
        @links   = links
        @options = options
      end

      # @param [#call] lookup
      #   A callable that can retrieve an association by its name
      # @param [Hash] options
      # @return Array[rel, resource]
      #   Returns the rel (registered type or URI) + the associated, mapped resource
      def map_to_resource_pair(parent_mapper, lookup, policy)
        [
          options.fetch(:rel) { policy.derive_rel_from_association(parent_mapper, self) },
          map_resource(lookup.call(name), policy)
        ]
      end

      def association_mapper(policy)
        return @mapper unless @mapper == Undefined
        policy.derive_mapper_from_association(self)
      end

    end
  end
end
