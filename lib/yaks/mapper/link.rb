module Yaks
  class Mapper
    class Link
      include Concord.new(:rel, :template, :options)
      include Util

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
        expand(
          variables.map.with_object({}) do |var, hsh|
            hsh[var] = callable.(var)
          end
        )
      end

      def map_to_resource_link(mapper)
        make_resource_link(
          rel,
          expand_with(mapper.method(:load_attribute)),
          resource_link_options(mapper)
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

      # Link properties defined in HAL
      # href
      # templated
      # typed
      # deprecation
      # name
      # profile
      # title
      # hreflang

      def resource_link_options(mapper)
        options = self.options
        options = options.merge(title: resolve_title(options[:title], mapper)) if options.has_key?(:title)
        options = options.merge( templated: true ) unless expand?
        options.reject{|k,v| [:expand].include? k}
      end

      def resolve_title(title_proc, mapper)
        Resolve(title_proc, mapper)
      end

      def make_resource_link(rel, uri, options)
        Resource::Link.new(rel, uri, options)
      end
    end
  end
end
