module PlexusSerializers
  class Serializer
    module ClassMethods

      def attributes(*attrs)
        @attributes ||= []
        @attributes.concat attrs

        attrs.each do |attr|
          unless method_defined?(attr)
            define_method attr do
              object.send attr
            end
          end
        end
      end

      def has_one(*attrs)
        @associations ||= []
        @associations.concat(attrs.map {|a| [:has_one, a] })
      end

      def has_many(*attrs)
        @associations ||= []
        @associations.concat(attrs.map {|a| [:has_many, a] })
      end

    end
  end
end
