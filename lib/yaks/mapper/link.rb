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
        return make_resource_link(template) unless expand?
        make_resource_link(
          expand(
            variables.map.with_object({}) do |var, hsh|
              hsh[var] = callable.(var)
            end
          )
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

      PROPAGATE_OPTIONS = [:name]

      def resource_link_options
        Hash[*
          PROPAGATE_OPTIONS.flat_map do |key|
            options[key] ? [key, options[key]] : []
          end
        ].merge(
          templated: !expand?
        )
      end

      def make_resource_link(uri)
        Resource::Link.new(rel, uri, resource_link_options)
      end
    end
  end
end
