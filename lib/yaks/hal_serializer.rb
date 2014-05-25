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
      result = result.merge(:_links => serialize_links(resource.links)) unless resource.links.empty?
      result = result.merge(:_embedded => serialize_embedded(resource.subresources)) unless resource.subresources.empty?
      result
    end

    def serialize_links(links)
      links.reduce({}, &method(:serialize_link))
    end

    def serialize_link(memo, link)
      hal_link = {href: link.uri}
      hal_link.merge!(link.options.reject{|k,_| k==:templated})
      hal_link.merge!(templated: true) if link.templated?

      memo[link.rel] = if singular?(link.rel)
                         hal_link
                       else
                         Array(memo[link.rel]) + [hal_link]
                       end
      memo
    end

    def singular?(rel)
      !options.fetch(:plural_links) { [] }.include?(rel)
    end

    def serialize_embedded(subresources)
      subresources.each_with_object({}) do |(rel, resources), memo|
        memo[rel] = if resources.collection?
                      resources.map( &method(:serialize_resource) )
                    else
                      serialize_resource(resources)
                    end
      end
    end

  end
end
