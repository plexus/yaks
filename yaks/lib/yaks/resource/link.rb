module Yaks
  class Resource
    class Link
      include Anima.new(:rel, :uri, :options),
              AttributeDefaults.new(options: {})

      def title
        options[:title]
      end

      def templated?
        options.fetch(:templated) { false }
      end
    end
  end
end
