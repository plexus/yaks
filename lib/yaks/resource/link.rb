module Yaks
  class Resource
    class Link
      include Equalizer.new(:rel, :uri, :options)

      attr_reader :rel, :uri, :options

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
