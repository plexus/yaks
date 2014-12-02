module Yaks
  class Format
    class CollectionJson < self
      register :collection_json, :json, 'application/vnd.collection+json'

      include FP

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def serialize_resource(resource)
        result = {
          version: "1.0",
          items: serialize_items(resource)
        }
        result[:href] = resource.self_link.uri if resource.self_link
        result[:links] = serialize_links(resource) if resource.collection? && resource.links.any?
        result[:template] = serialize_template(resource) if resource.find_form :template
        {collection: result}
      end

      # @param [Yaks::Resource] resource
      # @return [Array]
      def serialize_items(resource)
        resource.seq.map do |item|
          attrs = item.attributes.map do |name, value|
            {
              name: name,
              value: value
            }
          end
          result = { data: attrs }
          result[:href] = item.self_link.uri if item.self_link
          item.links.each do |link|
            next if link.rel.equal? :self
            result[:links] = [] unless result.key?(:links)
            result[:links] << {rel: link.rel, href: link.uri}
            result[:links].last[:name] = link.title if link.title
          end
          result
        end
      end

      def serialize_links(resource)
        result = []
        resource.links.each do |link|
          result << {href: link.uri, rel: link.rel}
        end
        result
      end

      def serialize_template(resource)
        fields = resource.find_form(:template).fields
        result = {data: []}
        fields.each do |field|
          result[:data] << {name: field.name, value: nil.to_s}
          result[:data].last[:prompt] = field.label if field.label
        end
        result
      end
    end
  end
end
