module Yaks
  class Format
    class JsonAPI < self
      register :json_api, :json, 'application/vnd.api+json'

      include FP

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def call(resource, env = {})
        main_collection = resource.seq.map(&method(:serialize_resource))

        { data: main_collection }.tap do |serialized|
          linked = resource.seq.each_with_object([]) do |res, array|
            serialize_linked_subresources(res.subresources, array)
          end
          serialized.merge!(linked: linked) unless linked.empty?
        end
      end

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def serialize_resource(resource)
        result = {type: pluralize(resource.type).to_sym}.merge(resource.attributes)

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
          hsh[resource.type] = serialize_link(resource)
        end
      end

      # @param [Yaks::Resource] resource
      # @return [Array, String]
      def serialize_link(resource)
        if resource.collection?
          {type: resource.type, ids: resource.map(&send_with_args(:[], :id))}
        else
          {type: pluralize(resource.type), id: resource[:id]}
        end
      end

      # @param [Hash] subresources
      # @param [Array] array
      # @return [Array]
      def serialize_linked_subresources(subresources, array)
        subresources.each do |resources|
          serialize_linked_resources(resources, array)
        end
      end

      # @param [Array] resources
      # @param [Array] linked
      # @return [Array]
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
        linked << serialize_resource(resource)
        serialize_linked_subresources(resource.subresources, linked)
      end

      def inverse
        Yaks::Reader::JsonAPI.new
      end
    end

    class Reader
    end
  end
end
