module Yaks
  class Serializer
    module Lookup

      def serializer_for(object_or_key)
        serializer_class_for(object_or_key).new(object_or_key, options)
      end

      def serializer_class_for(object_or_key)
        if object_or_key.respond_to?(:to_str) || object_or_key.is_a?(Symbol)
          serializer_lookup.(Object.const_get(Util.singular(Util.camelize(obj.to_s))))
        else
          serializer_lookup.(object_or_key)
        end
      end

    end
  end
end
