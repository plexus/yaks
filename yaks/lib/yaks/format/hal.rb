# -*- coding: utf-8 -*-

module Yaks
  class Format
    # Hypertext Application Language (http://stateless.co/hal_specification.html)
    #
    # A lightweight JSON Hypermedia message format.
    #
    # Options: +:plural_links+ In HAL, a single rel can correspond to
    # a single link, or to a list of links. Which rels are singular
    # and which are plural is application-dependant. Yaks assumes all
    # links are singular. If your resource might contain multiple
    # links for the same rel, then configure that rel to be plural. In
    # that case it will always be rendered as a collection, even when
    # the resource only contains a single link.
    #
    # @example
    #
    #   yaks = Yaks.new do
    #     format_options :hal, {plural_links: [:related_content]}
    #   end
    #
    class Hal < self
      register :hal, :json, 'application/hal+json'

      protected

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def serialize_resource(resource)
        # The HAL spec doesn't say explicitly how to deal missing values,
        # looking at client behavior (Hyperagent) it seems safer to return an empty
        # resource.
        #
        result = resource.attributes

        if resource.links.any?
          result = result.merge(_links: serialize_links(resource.links))
        end

        if resource.collection?
          result = result.merge(_embedded:
                                  serialize_embedded([resource]))
        elsif resource.subresources.any?
          result = result.merge(_embedded:
                                  serialize_embedded(resource.subresources))
        end

        result
      end

      # @param [Array] links
      # @return [Hash]
      def serialize_links(links)
        links.reduce({}, &method(:serialize_link))
      end

      # @param [Hash] memo
      # @param [Yaks::Resource::Link]
      # @return [Hash]
      def serialize_link(memo, link)
        hal_link = {href: link.uri}
        hal_link.merge!(link.options)

        memo[link.rel] = if singular?(link.rel)
                           hal_link
                         else
                           (memo[link.rel] || []) + [hal_link]
                         end
        memo
      end

      # @param [String] rel
      # @return [Boolean]
      def singular?(rel)
        !options.fetch(:plural_links) { [] }.include?(rel)
      end

      # @param [Array] subresources
      # @return [Hash]
      def serialize_embedded(subresources)
        subresources.each_with_object({}) do |sub, memo|
          memo[sub.rels.first] = if sub.collection?
                                   sub.map( &method(:serialize_resource) )
                                 elsif sub.null_resource?
                                   nil
                                 else
                                   serialize_resource(sub)
                                 end
        end
      end

    end
  end
end
