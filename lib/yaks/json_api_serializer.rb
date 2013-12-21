# -*- coding: utf-8 -*-

module Yaks
  class JsonApiSerializer < Serializer
    def serialize
      Primitivize.(
        {
          pluralize(profile_name.to_s) => Array(attributes.merge(Yaks::Hash(:links => serialize_embedded)))
        }
      )
    end
    alias to_json_api serialize

    def serialize_embedded
      Yaks::Hash(subresources.map &μ(:serialize_resource))
    end

    def serialize_resource(name, resource)
      [ name, resource.respond_to?(:members) ? resource.members.map(&σ(:[], :id)) : resource[:id] ]
    end
  end
end
