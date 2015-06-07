module Yaks
  module Reader
    class JsonAPI
      def call(parsed_json, _env = {})
        included = parsed_json['included'].nil? ? {} : parsed_json['included'].dup

        if parsed_json['data'].is_a?(Array)
          CollectionResource.new(
            attributes: parsed_json['meta'].nil? ? nil : {meta: parsed_json['meta']},
            members: parsed_json['data'].map { |data| call('data'  => data, 'included' => included) }
          )
        else
          attributes = parsed_json['data'].dup
          links = attributes.delete('links') || {}
          relationships = attributes.delete('relationships') || {}
          type  = attributes.delete('type')
          attributes.merge!(attributes.delete('attributes') || {})

          embedded   = convert_embedded(Hash[relationships], included)
          links      = convert_links(Hash[links])

          Resource.new(
            type: Util.singularize(type),
            attributes: Util.symbolize_keys(attributes),
            subresources: embedded,
            links: links
          )
        end
      end

      def convert_embedded(relationships, included)
        relationships.flat_map do |rel, relationship|
          # A Link doesn't have to contain a `data` member.
          # It can contain URLs instead, or as well, but we are only worried about *embedded* links here.
          data = relationship['data']
          # Resource data MUST be represented as one of the following:
          #
          # * `null` for empty to-one relationships.
          # * a "resource identifier object" for non-empty to-one relationships.
          # * an empty array ([]) for empty to-many relationships.
          # * an array of resource identifier objects for non-empty to-many relationships.
          if data.nil?
            NullResource.new(rels: [rel])
          elsif data.is_a? Array
            if data.empty?
              NullResource.new(collection: true, rels: [rel])
            else
              CollectionResource.new(
                members: data.map { |link|
                  data = included.find{ |item| (item['id'] == link['id']) && (item['type'] == link['type']) }
                  call('data'  => data, 'included' => included)
                },
                rels: [rel]
              )
            end
          else
            data = included.find{ |item| (item['id'] == data['id']) && (item['type'] == data['type']) }
            call('data'  => data, 'included' => included).with(rels: [rel])
          end
        end.compact
      end

      def convert_links(links)
        links.map do |rel, link|
          Resource::Link.new(rel: rel.to_sym, uri: link)
        end
      end
    end
  end
end
