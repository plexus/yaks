module Yaks
  class Format
    class CollectionJson < self
      Format.register self, :collection_json, 'application/vnd.collection+json'

      include FP

      # @param [Yaks:Resource] resource
      # @return [Hash]
      def serialize_resource(resource)
        result = {
          version: "1.0",
          items: serialize_items(resource)
        }
        result[:href] = resource.self_link.uri if resource.self_link
        {collection: result}
      end

      # @param [Yaks::Resource] resource
      # @return [Array]
      def serialize_items(resource)
        resource.map do |item|
          attrs = item.attributes.map do |name, value|
            {
              name: name,
              value: value
            }
          end
          result = { data: attrs }
          result[:href] = item.self_link.uri if item.self_link
          item.links.each do |link|
            next if link.rel == :self
            result[:links] = [] unless result.key?(:links)
            result[:links] << {rel: link.rel, href: link.uri}
            result[:links].last[:name] = link.name if link.name
          end
          result
        end
      end
    end
  end
end
