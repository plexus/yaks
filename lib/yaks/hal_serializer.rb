# -*- coding: utf-8 -*-

# application/hal+json
#
# see examples/hal01.rb

module Yaks
  class HalSerializer < Serializer

    def call
      serialize_resource(resource)
    end
    alias serialize call

    protected

    def serialize_resource(resource)
      # The HAL spec doesn't say explicitly how to deal missing values,
      # looking at client behavior (Hyperagent) it seems safer to return an empty
      # resource.
      #
      # return nil if resource.is_a? NullResource
      result = resource.attributes
      result = result.put(:_links, serialize_links(resource.links)) unless resource.links.empty?
      result = result.put(:_embedded, serialize_embedded(resource.subresources)) unless resource.subresources.empty?
      result
    end

    def serialize_links(links)
      links.reduce(Yaks::Hash(), &method(:serialize_link))
    end

    def serialize_link(memo, link)
      memo.put(link.rel) {|links|
        slink = {href: link.uri}.merge(link.options.reject{|k,_| k==:templated})
        slink.merge!(templated: true) if link.templated?
        singular?(link.rel) ? slink : Yaks::List(links).cons(slink)
      }
    end

    def singular?(rel)
      options.fetch(:singular_links) { [] }.include?(rel)
    end

    def serialize_embedded(subresources)
      subresources.map do |rel, resources|
        [
          rel,
          if resources.collection?
            resources.map( &method(:serialize_resource) )
          else
            serialize_resource(resources)
          end
        ]
      end
    end

  end
end
