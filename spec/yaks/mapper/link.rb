module Yaks
  class Mapper
    class Link
      include Concord.new(:rel, :template)

      def rel?(rel)
        self.rel == rel
      end

      def expand(variables)
        uri_template.expand(variables)
      end

      def uri_template
        @uri_template ||= URITemplate.new(template)
      end

      def variables
        uri_template.variables
      end

      def expand_to_resource_link(variables)
        Resource::Link.new(rel, expand(variables))
      end
    end
  end
end
