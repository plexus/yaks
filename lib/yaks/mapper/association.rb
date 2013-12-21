module Yaks
  class Mapper
    class Association
      include Equalizer.new(:name, :mapper, :links)

      attr_reader :name, :key, :mapper, :links, :options
      private :mapper, :links, :options

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

      def map_to_resource_pair(loader)
        [ key, map_resource(loader.(name)) ]
      end
    end
  end
end
