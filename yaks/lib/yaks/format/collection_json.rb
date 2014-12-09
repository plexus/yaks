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
        result[:links] = serialize_links(resource) if links? resource
        result[:queries] = serialize_queries(resource) if queries? resource
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
        resource.links.each_with_object([]) do |link, result|
          result << { href: link.uri, rel: link.rel }
        end
      end

      def serialize_queries(resource)
        resource.forms.each_with_object([]) do |f, result|
          next unless f.method == "GET"

          # `action` in Yaks is not required,
          # but it is for Collection+JSON
          unless f.action.nil?
            result << { rel: f.name, href: f.action }
            result.last[:prompt] = f.title if f.title

            f.fields.each do |field|
              result.last[:data] = [] unless result.last.key? :data
              result.last[:data] << { name: field.name, value: nil.to_s }
              result.last[:data].last[:prompt] = field.label if field.label
            end
          end
        end
      end

      def queries?(resource)
        resource.forms.any? { |f| f.method == 'GET' }
      end

      def links?(resource)
        resource.collection? && resource.links.any?
      end
    end
  end
end
