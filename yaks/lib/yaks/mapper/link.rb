module Yaks
  class Mapper
    # A Yaks::Mapper::Link is part of a mapper's configuration. It captures
    # what is set through the mapper's class level `#link` function, and is
    # capable of generating a `Yaks::Resource::Link` for a given mapper
    # instance (and hence subject).
    #
    # @example
    #   link :self, 'http://api.foo.org/users/{id}', title: ->{ "User #{object.name}" }
    #   link :profile, 'http://apidocs.foo.org/profiles/users'
    #   link 'http://apidocs.foo.org/rels/friends', 'http://api.foo.org/users/{id}/friends?page={page}', expand: [:id]
    #
    # It takes a relationship identifier, a URI template and an options hash.
    #
    # @param rel [Symbol|String] Either a registered relationship type (Symbol)
    #   or a relationship URI. See [RFC5988 Web Linking](http://tools.ietf.org/html/rfc5988)
    # @param template [String] A [RFC6570](http://tools.ietf.org/html/rfc6570) URI template
    # @param template [Symbol] A method name that generates the link. No more expansion is done afterwards
    # @option expand [Boolean] pass false to pass on the URI template in the response,
    #   instead of expanding the variables
    # @option expand [Array[Symbol]] pass a list of variable names to only expand those,
    #   and return a partially expanded URI template in the response
    # @option title [String] Give the link a title
    # @option title [#to_proc] Block that returns the title. If it takes an argument,
    #   it will receive the mapper instance as argument. Otherwise it is evaluated in the mapper context
    class Link
      extend Forwardable, Util
      include Attributes.new(:rel, :template, options: {}), Util

      def self.create(*args)
        args, options = extract_options(args)
        new(rel: args[0], template: args[1], options: options)
      end

      def add_to_resource(resource, mapper, _context)
        return resource.with(links: resource.links.reject {|link| link.rel?(rel)}) if options[:remove]

        resource_link = map_to_resource_link(mapper)
        return resource unless resource_link

        if options[:replace]
          resource.with(links: resource.links.reject {|link| link.rel?(rel)} << resource_link)
        else
          resource.add_link(resource_link)
        end
      end

      def rel?(rel)
        rel().eql? rel
      end

      # A link is templated if it does not expand, or only partially
      def templated?
        !options.fetch(:expand) { true }.equal? true
      end

      def map_to_resource_link(mapper)
        return unless mapper.expand_value(options.fetch(:if, true))

        uri = mapper.expand_uri(template, options.fetch(:expand, true))
        return if uri.nil?

        Resource::Link.new(
          rel: rel,
          uri: uri,
          options: resource_link_options(mapper)
        )
      end

      def resource_link_options(mapper)
        options = options()
        options = options.merge(title: Resolve(options[:title], mapper)) if options.key?(:title)
        options = options.merge(templated: true) if templated?
        options.reject{|key| [:expand, :replace, :if].include? key }
      end

    end
  end
end
