# -*- coding: utf-8 -*-

# application/hal+json
#
# see examples/hal01.rb

module Yaks
  class HalSerializer < Serializer

    def serialize
      Primitivize.(serialize_resource(resource))
    end
    alias to_hal serialize

    protected

    def serialize_resource(resource)
      if resource.collection?
        resource.map(&μ(:serialize_resource))
      else
        result = resource.attributes
        result = result.put(:_links, serialize_links(resource.links))
        result = result.put(:_embedded, serialize_embedded(resource.subresources)) unless resource.subresources.empty?
        result
      end
    end

    def serialize_links(links)
      links.reduce(Yaks::Hash(), &μ(:serialize_link))
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
      subresources.map &μ(:serialize_subresource)
    end

    def serialize_subresource(name, resource)
      [name, serialize_resource(resource) ]
    end

    def cond_merge(hash, *optionals)
      optionals.reduce(hash) do |memo, (key, value, cond)|
        cond ? memo.merge(key => value) : memo
      end
    end
  end
end
