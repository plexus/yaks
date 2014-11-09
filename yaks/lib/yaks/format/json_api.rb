# -*- coding: utf-8 -*-

module Yaks
  class Format
    class JsonAPI < self
      register :json_api, :json, 'application/vnd.api+json'

      include FP

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def call(resource)
        main_collection = resource.seq.map(&method(:serialize_resource))

        { pluralize(resource.type) => main_collection }.tap do |serialized|
          linked = resource.seq.each_with_object({}) do |res, hsh|
            serialize_linked_subresources(res.subresources, hsh)
          end
          serialized.merge!(linked: linked) unless linked.empty?
        end
      end

      # @param [Yaks::Resource] resource
      # @return [Hash]
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

      # @param [Yaks::Resource] subresource
      # @return [Hash]
      def serialize_links(subresources)
        subresources.each_with_object({}) do |resource, hsh|
          next if resource.null_resource?
          key = resource.collection? ? pluralize(resource.type) : resource.type
          hsh[key] = serialize_link(resource)
        end
      end

      # @param [Yaks::Resource] resource
      # @return [Array, String]
      def serialize_link(resource)
        resource.collection? ? resource.map(&send_with_args(:[], :id)) : resource[:id]
      end

      # @param [Hash] subresources
      # @param [Hash] hsh
      # @return [Hash]
      def serialize_linked_subresources(subresources, hsh)
        subresources.each do |resources|
          serialize_linked_resources(resources, hsh)
        end
      end

      # @param [Array] resources
      # @param [Hash] linked
      # @return [Hash]
      def serialize_linked_resources(subresource, linked)
        subresource.seq.each_with_object(linked) do |resource, memo|
          serialize_subresource(resource, memo)
        end
      end

      # {shows => [{id: 3, name: 'foo'}]}
      #
      # @param [Yaks::Resource] resource
      # @param [Hash] linked
      # @return [Hash]
      def serialize_subresource(resource, linked)
        key = pluralize(resource.type)
        set = linked.fetch(key) { Set.new }
        linked[key] = (set << serialize_resource(resource))
        serialize_linked_subresources(resource.subresources, linked)
      end
    end
  end
end
