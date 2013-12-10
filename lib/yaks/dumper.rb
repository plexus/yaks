module Yaks
  def self.default_serializer_lookup(obj)
    Object.const_get("#{obj.class.name}Serializer")
  end

  class Dumper
    def initialize(lookup = Yaks.method(:default_serializer_lookup), format = :json_api)
    end

    def call

    end
  end
end
