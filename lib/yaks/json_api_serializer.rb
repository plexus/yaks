# -*- coding: utf-8 -*-

module Yaks
  class JsonApiSerializer < Serializer
    def serialize
      serialized = {
        pluralize(profile_name.to_s) => Array(serialize_resource(resource))
      }
      serialized.merge!('linked' => serialize_linked(subresources)) if options[:embed] == :resources
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
      [ name, resource.collection? ? resource.map(&σ(:[], :id)) : resource[:id] ]
    end

    def serialize_linked(subresources)
      result = {}
      subresources.each do |name, resources|
        resources.each do |resource|
          result = result.merge(serialize_subresource(resource)) {|old, new| old.concat(new) }
        end
      end
      result
    end

    def serialize_subresource(resource)
      {
        pluralize(profile_registry.find_by_uri(resource.profile).to_s) => [serialize_resource(resource)]
      }.merge(serialize_linked(resource.subresources)) {|old, new| old.concat(new) }
    end
  end
end
