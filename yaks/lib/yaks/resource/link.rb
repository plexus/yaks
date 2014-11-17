module Yaks
  class Resource
    class Link
      include Attributes.new(:rel, :uri, options: {})

      def title
        options[:title]
      end

      def templated?
        options.fetch(:templated) { false }
      end

      def rel?(rel)
        rel().eql? rel
      end
    end
  end
end
