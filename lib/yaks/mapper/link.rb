module Yaks
  class Mapper
    class Link
      extend Forwardable, Typecheck
      include Concord.new(:rel, :template, :options)
      include Util

      def_delegators :uri_template, :expand, :expand_partial

      def initialize(rel, template, options)
        @rel, @template, @options = rel, template, options
      end

      def rel?(rel)
        rel().eql? rel
      end

      def expand
        options.fetch(:expand) { true }
      end
      alias expand? expand

      # link 'http://{only}/{certain}/{variables}/{not_expanded}, expand: [:only, :certain, :variables]
      def expand_partial?
        expand.respond_to?(:map)
      end

      def expand_with(lookup)
        # link :method_that_returns_link
        return lookup.call(template) if template.is_a? Symbol

        # link 'http://link/{template}', expand: false
        # link 'http://link/{template}', expand: [:only, :some, :fields]
        return template unless expand?

        if expand_partial?
          uri_template.expand_partial(expansion_mapping(lookup)).to_s
        else
          uri_template.expand(expansion_mapping(lookup))
        end
      end
      typecheck '#call -> String', :expand_with

      def map_to_resource_link(mapper)
        Resource::Link.new(
          rel,
          expand_with(mapper.method(:load_attribute)),
          resource_link_options(mapper)
        )
      end
      typecheck '#load_attribute -> Yaks::Resource::Link', :map_to_resource_link

      def uri_template
        URITemplate.new(template)
      end

      def template_variables
        if expand_partial?
          expand.map(&:to_s)
        else
          uri_template.variables
        end
      end

      def expansion_mapping(lookup)
        template_variables.map.with_object({}) do |var, hsh|
          hsh[var] = lookup.call(var)
        end
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
        options = options()
        options = options.merge(title: Resolve(options[:title], mapper)) if options.key?(:title)
        options = options.merge(templated: true) if templated?
        options.reject{|key| key.equal? :expand }
      end

      def templated?
        !expand? || expand_partial?
      end
    end
  end
end
