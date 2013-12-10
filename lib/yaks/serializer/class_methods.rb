module Yaks
  class Serializer
    module ClassMethods

      protected

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
        attrs.each do |attr|
          unless method_defined?(attr)
            define_method attr do
              object.send attr
            end
          end
        end
      end

      def has_many(*attrs)
        @associations ||= []
        @associations.concat(attrs.map {|a| [:has_many, a] })
        attrs.each do |attr|
          unless method_defined?(attr)
            define_method attr do
              object.send attr
            end
          end
        end
      end

      def root_key(key)
        @root_key = key
      end

      def identity_key(id_key)
        @identity_key = id_key
      end

      public

      def _attributes
        @attributes
      end

      def _associations
        @associations
      end

      def _root_key
        @root_key ||
          self.name
              .sub(/Serializer$/, '')
              .gsub(/(?<!^)[A-Z](?=[a-z$])|(?<=[a-z])[A-Z]/) {|match, x| '_' + match }
              .downcase + 's'
      end

      def _identity_key
        @identity_key || :id
      end

      def _attributes
        @attributes
      end

    end
  end
end
