module Yaks
  class Mapper
    class Association
      include Equalizer.new(:name, :_mapper, :links)
      include SharedOptions

      attr_reader :name, :key, :links, :options
      private :links, :options

      def initialize(name, key, mapper, links, options)
        @name    = name
        @key     = key
        @mapper  = mapper
        @links   = links
        @options = options
      end

      def self_link
        links.detect {|link| link.rel? :self }
      end

      # @param [Symbol] src_type
      #   The profile type of the resource that contains the association
      # @param [#call] loader
      #   A callable that can retrieve an association by its name
      # @param [Hash] options
      # @return Array[rel, resource]
      #   Returns the rel (registered type or URI) + the associated, mapped resource
      def map_to_resource_pair(src_type, loader, options)
        [
          options[:rel_registry].lookup(src_type, key),
          map_resource(loader.(name), options)
        ]
      end

      private

      def mapper(opts = nil)
        return _mapper unless _mapper == Undefined
        opts[:policy].derive_missing_mapper_for_association(self)
      end

      def _mapper
        @mapper
      end
    end
  end
end
