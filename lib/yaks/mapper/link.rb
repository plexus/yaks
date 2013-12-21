module Yaks
  class Mapper
    class Link
      include Concord.new(:rel, :template, :options)

      def initialize(rel, template, options = {})
        @rel, @template, @options = rel, template, options
      end

      def rel?(rel)
        self.rel == rel
      end

      def expand?
        options.fetch(:expand) {true}
      end

      def expand_with(callable)
        return template unless expand?
        expand_to_resource_link(
          variables.map.with_object({}) do |var, hsh|
            hsh[var] = callable.(var)
          end
        )
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
