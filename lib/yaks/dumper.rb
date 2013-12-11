module Yaks
  class Dumper
    include Util

    def initialize(options = {})
      @lookup       = options.fetch(:serializer_lookup) { Yaks.default_serializer_lookup }
      format        = options.fetch(:format) { :json_api }
      @format       = Yaks.const_get("Fold#{camelize(format.to_s)}") if format.is_a?(Symbol)
      @options      = options
    end

    def dump(type, objects)
      serializer = @lookup.(type).new(@options.merge(root_key: type))
      Primitivize.(
        @format.new(
          serializer.serializable_collection(objects)
        ).fold
      )
    end
    alias call dump

  end
end
