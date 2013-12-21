module Yaks
  class HalSerializer < Serializer
    def serialize
      Primitivize.(
        resource.attributes.merge(Yaks::Hash(
            _links: serialize_links,
            _embedded: serialize_embedded
        ))
      )
    end
    alias to_hal serialize

    def serialize_links
      {}
    end

    def serialize_embedded
      {}
    end

  end
end
