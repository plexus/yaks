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
        output[:meta] = resource.attributes[:meta] if resource.attributes[:meta]
        output
      end

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def serialize_links(links)
        links.inject({}) do |hash, link|
          hash.update(link.rel => link.uri)
        end
      end

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def serialize_resource(resource)
        result = {type: pluralize(resource.type).to_sym}.merge(resource.attributes)

        links = serialize_subresource_links(resource.subresources)
        result[:links] = links unless links.empty?

        if resource.self_link && !result.key?(:href)
          result[:href]  = resource.self_link.uri
        end

        result
      end

      # @param [Yaks::Resource] subresource
      # @return [Hash]
      def serialize_subresource_links(subresources)
        subresources.each_with_object({}) do |resource, hsh|
          next if resource.null_resource?
          hsh[resource.rels.first.sub(/^rel:/, '')] = serialize_subresource_link(resource)
        end
      end

      # @param [Yaks::Resource] resource
      # @return [Array, String]
      def serialize_subresource_link(resource)
        if resource.collection?
          {linkage: resource.map{|r| {type: pluralize(r.type), id: r[:id]} }}
        else
          {linkage: {type: pluralize(resource.type), id: resource[:id]}}
        end
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

      # {shows => [{id: 3, name: 'foo'}]}
      #
      # @param [Yaks::Resource] resource
      # @param [Hash] included
      # @return [Hash]
      def serialize_subresource(resource, included)
        included << serialize_resource(resource) unless included.any? do |item|
          item[:id].equal?(resource[:id]) && item[:type].equal?(pluralize(resource.type).to_sym)
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
