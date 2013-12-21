# -*- coding: utf-8 -*-

module Yaks
  class JsonApiSerializer < Serializer
    def serialize
      serialized = Yaks::Hash(
        pluralize(profile_name.to_s) => resource.map(&method(:serialize_resource))
      )

      if options[:embed] == :resources
        linked = resource.reduce(Yaks::Hash()) do |memo, res|
          serialize_linked_subresources(res.subresources, memo)
        end
        serialized = serialized.put('linked', linked)
      end

      Primitivize.( serialized )
    end
    alias to_json_api serialize

    def serialize_resource(resource)
      result = resource.attributes
      result = result.merge(Yaks::Hash(:links => serialize_links(resource.subresources))) unless resource.subresources.empty?
      result
    end

    def serialize_links(subresources)
      Yaks::Hash(subresources.map &μ(:serialize_link))
    end

    def serialize_link(name, resource)
      if options[:embed] == :links
        [ name, resource.uri ]
      else
        [ name, resource.collection? ? resource.map(&σ(:[], :id)) : resource[:id] ]
      end
    end

    def serialize_linked_subresources(subresources, linked)
      subresources.reduce(linked) do |memo, name, resources|
        serialize_linked_resources(resources, memo)
      end
    end

    def serialize_linked_resources(resources, linked)
      resources.reduce(linked) do |memo, resource|
        serialize_subresource(resource, memo)
      end
    end

    # {shows => [{id: 3, name: 'foo'}]}
    def serialize_subresource(resource, linked)
      key = pluralize(profile_registry.find_by_uri(resource.profile).to_s)
      set = linked.fetch(key) { Hamster.set }
      linked = linked.put(key, set << serialize_resource(resource))
      serialize_linked_subresources(resource.subresources, linked)
    end
  end
end
