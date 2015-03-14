module Yaks
  module Reader
    class JsonAPI
      def call(parsed_json, env = {})
        attributes = parsed_json['data'].first.dup
        links = attributes.delete('links') || {}
        linked = parsed_json['linked'].nil? ? {} : parsed_json['linked'].dup
        embedded   = convert_embedded(links, linked)
        Resource.new(
            type: Util.singularize(attributes.delete('type')[/\w+$/]),
            attributes: Util.symbolize_keys(attributes),
            subresources: embedded,
            links: []
        )
      end

      def convert_embedded(links, linked)
        links.flat_map do |rel, link_data|
          # If this is a compound link, the link_data will contain either
          # * 'type' and 'id' for a one to one
          # * 'type' and 'ids' for a homogeneous to-many relationship
          # * 'data' being an array where each member has 'type' and 'id' for heterogeneous
          if !link_data['type'].nil? && !link_data['id'].nil?
            resource = linked.find{ |item| (item['id'] == link_data['id']) && (item['type'] == link_data['type']) }
            call({'data'  => [resource], 'linked' => linked}).with(rels: [rel])
          elsif !link_data['type'].nil? && !link_data['ids'].nil?
            resources = linked.select{ |item| (link_data['ids'].include? item['id']) && (item['type'] == link_data['type']) }
            members = resources.map { |r|
              call({'data'  => [r], 'linked' => linked})
            }
            CollectionResource.new(
                members: members,
                type: link_data['type'],
                rels: [rel]
            )
          elsif link_data['data'].present?
            CollectionResource.new(
                members: link_data['data'].map { |link|
                  resource = linked.find{ |item| (item['id'] == link['id']) && (item['type'] == link['type']) }
                  call({'data'  => [resource], 'linked' => linked})
                },
                rels: [rel]
            )
          end
        end.compact
      end
    end
  end
end
