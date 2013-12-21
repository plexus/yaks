module Yaks
  class Mapper
    class Association
      include Equalizer.new(:name, :mapper, :links)

      attr_reader :name, :key, :mapper, :links

      def initialize(name, key, mapper, links)
        @name   = name
        @key    = key
        @mapper = mapper
        @links  = links
      end

      def self_link
        links.detect {|link| link.rel? :self }
      end

    end
  end
end
