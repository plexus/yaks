module Yaks
  class Mapper
    class Association
      include Equalizer.new(:name, :mapper, :links)

      attr_reader :name, :mapper, :links

      def initialize(name, mapper, links)
        @name   = name
        @mapper = mapper
        @links  = links
      end

      def self_link
        links.detect {|link| link.rel? :self }
      end

    end
  end
end
