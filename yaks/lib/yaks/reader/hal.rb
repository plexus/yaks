module Yaks
  module Reader
    class Hal

      def call(parsed_json, env = {})
        attributes = parsed_json.dup
        links      = convert_links(attributes.delete('_links') || {})
        embedded   = convert_embedded(attributes.delete('_embedded') || {})


        Resource.new(
          type: attributes.delete('type') || type_from_links(links),
          attributes: Util.symbolize_keys(attributes),
          links: links,
          subresources: embedded
        )
      end

      def type_from_links(links)
        profile = links.detect {|l| l.rel?(:profile)}
        profile.uri[/\w+$/] if profile
      end

      def convert_links(links)
        Set[*
            links.flat_map do |rel, link|
              array(link).map do |l|
                options = Util.symbolize_keys(Util.slice_hash(l, 'title', 'templated'))
                rel = rel.to_sym if Yaks::Identifier::LinkRelation.iana?(rel)
                Resource::Link.new(rel: rel, uri: l['href'], options: options)
              end
            end
           ]
      end

      def array(x)
        x.instance_of?(Array) ? x : [x]
      end


      def convert_embedded(embedded)
        embedded.flat_map do |rel, resource|
          case resource
          when nil
            NullResource.new
          when Array
            if resource.empty?
              NullResource.new(collection: true)
            else
              CollectionResource.new(
                members: resource.map { |r| call(r).type(Util.singularize(rel[/\w+$/])) }
              )
            end
          else
            call(resource)
          end.rels([rel])
        end
      end

    end
  end
end
