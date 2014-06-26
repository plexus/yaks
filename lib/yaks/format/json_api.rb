# -*- coding: utf-8 -*-

module Yaks
  class Format
    class JsonApi < self
      Format.register self, :json_api, 'application/vnd.api+json'

      include FP

      def call(resource)
        main_collection = resource.map(&method(:serialize_resource))

        { pluralize(resource.type) => main_collection }.tap do |serialized|
          linked = resource.each_with_object({}) do |res, hsh|
            serialize_linked_subresources(res.subresources, hsh)
          end
          serialized.merge!(linked: linked) unless linked.empty?
        end
      end

      def serialize_resource(resource)
        result = resource.attributes

        unless resource.subresources.empty?
          result[:links] = serialize_links(resource.subresources)
        end

        if resource.self_link && !result.key?(:href)
          result[:href]  = resource.self_link.uri
        end

        result
      end

      def serialize_links(subresources)
        subresources.each_with_object({}) do |(name, resource), hsh|
          next if resource.is_a? NullResource
          key = resource.collection? ? pluralize(resource.type) : resource.type
          hsh[key] = serialize_link(resource)
        end
      end

      def serialize_link(resource)
        resource.collection? ? resource.map(&send_with_args(:[], :id)) : resource[:id]
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
        key = pluralize(resource.type)
        set = linked.fetch(key) { Set.new }
        linked[key] = (set << serialize_resource(resource))
        serialize_linked_subresources(resource.subresources, linked)
      end
    end
  end
end
