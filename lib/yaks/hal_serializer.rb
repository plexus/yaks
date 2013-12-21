# -*- coding: utf-8 -*-

# application/hal+json
#
# see examples/hal01.rb

module Yaks
  class HalSerializer < Serializer

    def serialize
      Primitivize.(
        attributes.merge(Yaks::Hash(
            _links: serialize_links,
            _embedded: serialize_embedded
        ))
      )
    end
    alias to_hal serialize

    protected

    def serialize_links
      links.reduce(Yaks::Hash(), &μ(:serialize_link))
    end

    def serialize_link(memo, link)
      memo.put(link.rel) {|links|
        slink = cond_merge(
          {href: link.uri},
          [:name, link.name, link.name],
          [:templated, true, link.templated?]
        )
        singular?(link.rel) ? slink : Yaks::List(links).cons(slink)
      }
    end

    def singular?(rel)
      options.fetch(:singular_links) { [] }.include?(rel)
    end

    def serialize_embedded
      subresources.map &μ(:serialize_resource)
    end

    def serialize_resource(name, resource)
      recurse = ->(resource) { self.class.new(resource, options).to_hal }
      [name, resource.respond_to?(:members) ? resource.members.map(&recurse) : recurse.(resource) ]
    end

    def cond_merge(hash, *optionals)
      optionals.reduce(hash) do |memo, (key, value, cond)|
        cond ? memo.merge(key => value) : memo
      end
    end
  end
end
