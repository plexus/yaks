module Yaks
  class Dumper
    include Util

    def initialize(options = {})
      @lookup = options.fetch(:lookup) { Yaks.method(:default_serializer_lookup) }
      format  = options.fetch(:format) { :json_api }
      @format = Yaks.const_get("Fold#{camelize(format.to_s)}") if format.is_a?(Symbol)
    end

    def call(type, objects)
      serializer = @lookup.(type).new
      Primitivize.(
        @format.new(
          serializer.serialize_collection(objects)
        ).fold
      )
    end
  end
end
