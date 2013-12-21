module Yaks
  class Resource
    class Link
      include Equalizer.new(:rel, :uri)

      attr_reader :rel, :uri, :options
      private :options

      def initialize(rel, uri, options)
        @rel, @uri, @options = rel, uri, options
      end

      def name
        options[:name]
      end

      def templated?
        options.fetch(:templated) { false }
      end
    end
  end
end
