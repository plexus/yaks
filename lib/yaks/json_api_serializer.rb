# -*- coding: utf-8 -*-

module Yaks
  class JsonApiSerializer < Serializer
    def serialize
      serialized = {
        pluralize(profile_name.to_s) => resource.map(&method(:serialize_resource))
      }

      if options[:embed] == :resources
        linked = resource.each_with_object({}) do |res, hsh|
          serialize_linked_subresources(res.subresources, hsh)
        end
        serialized = serialized.merge('linked' => linked)
      end

      Primitivize.( serialized )
    end
    alias to_json_api serialize

    def serialize_resource(resource)
      result = resource.attributes
      result = result.merge(:links => serialize_links(resource.subresources)) unless resource.subresources.empty?
      result
    end

    def serialize_links(subresources)
      Hash[*subresources.map(&method(:serialize_link))]
    end

    def serialize_link(name, resource)
      if options[:embed] == :links
        [ name, resource.uri ]
      else
        [ name, resource.collection? ? resource.map(&curry_symbol(:[], :id)) : resource[:id] ]
      end
    end

    def serialize_linked_subresources(subresources, hsh)
      subresources.each_with_object(hsh) do |(name, resources), hsh|
        serialize_linked_resources(resources, hsh)
      end
    end

    def serialize_linked_resources(resources, linked)
      resources.each_with_object(linked) do |resource, memo|
        serialize_subresource(resource, memo)
      end
    end

    # {shows => [{id: 3, name: 'foo'}]}
    def serialize_subresource(resource, linked)
      key = pluralize(profile_registry.find_by_uri(resource.profile).to_s)
      set = linked.fetch(key) { Set.new }
      linked = linked[key] = (set << serialize_resource(resource))
      serialize_linked_subresources(resource.subresources, linked)
    end
  end
end
