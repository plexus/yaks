module Yaks
  class Format
    class JsonAPI < self
      register :json_api, :json, 'application/vnd.api+json'

      include FP

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def call(resource, _env = nil)
        output = {}
        if resource.collection?
          output[:data]  = resource.map(&method(:serialize_resource))
          output[:links] = serialize_links(resource.links) if resource.links.any?
        else
          output[:data] = serialize_resource(resource)
        end
        included = resource.seq.each_with_object([]) do |res, array|
          serialize_included_subresources(res.subresources, array)
        end
        output[:included] = included if included.any?
        output[:meta] = resource[:meta] if resource[:meta]

        output
      end

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def serialize_links(links)
        links.each_with_object({}) do |link, hash|
          hash[link.rel] = link.uri
        end
      end

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def serialize_resource(resource)
        result = {}
        result[:type] = pluralize(resource.type)
        result[:id]   = resource[:id].to_s if resource[:id]

        attributes = resource.attributes.reject { |k| k.equal?(:id) }
        result[:attributes] = attributes if attributes.any?

        relationships = serialize_relationships(resource.subresources)
        result[:relationships] = relationships unless relationships.empty?
        links = serialize_links(resource.links)
        result[:links] = links unless links.empty?

        result
      end

      # @param [Array] subresources
      # @return [Hash]
      def serialize_relationships(subresources)
        subresources.each_with_object({}) do |resource, hsh|
          next if resource.null_resource?
          hsh[resource.rels.first.sub(/^rel:/, '')] = serialize_relationship(resource)
        end
      end

      # @param [Yaks::Resource] resource
      # @return [Array, Hash]
      def serialize_relationship(resource)
        return {data: resource.map{|r| {type: pluralize(r.type), id: r[:id].to_s} }} if resource.collection?
        {data: {type: pluralize(resource.type), id: resource[:id].to_s}}
      end

      # @param [Hash] subresources
      # @param [Array] array
      # @return [Array]
      def serialize_included_subresources(subresources, array)
        subresources.each do |resources|
          serialize_included_resources(resources, array)
        end
      end

      # @param [Array] resources
      # @param [Array] included
      # @return [Array]
      def serialize_included_resources(subresource, included)
        subresource.seq.each_with_object(included) do |resource, memo|
          serialize_subresource(resource, memo)
        end
      end

      # {shows => [{id: '3', name: 'foo'}]}
      #
      # @param [Yaks::Resource] resource
      # @param [Hash] included
      # @return [Hash]
      def serialize_subresource(resource, included)
        included << serialize_resource(resource) unless included.any? do |item|
          item[:id].eql?(resource[:id].to_s) && item[:type].eql?(pluralize(resource.type))
        end
        serialize_included_subresources(resource.subresources, included)
      end

      def inverse
        Yaks::Reader::JsonAPI.new
      end
    end

    class Reader
    end
  end
end
