module Yaks
  class JsonApiSerializer < Serializer
    include Util

    def serialize
    end
    alias to_json_api serialize
  end
end
