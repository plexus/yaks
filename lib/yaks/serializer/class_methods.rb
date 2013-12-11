module Yaks
  class Serializer
    module ClassMethods
      include Forwardable
      include Util

      protected

      def inherited(desc)
        attributes
        has_one
      end

      def delegate_to_object(*attrs)
        attrs.reject(&method(:method_defined?)).each(&method(:def_delegator).to_proc.curry.(:object))
      end

      def attributes(*attrs)
        _attributes.concat attrs
        delegate_to_object(*attrs)
      end

      def has_one(*attrs)
        _associations.concat(attrs.map {|a| [:has_one, a] })
        delegate_to_object(*attrs)
      end

      def has_many(*attrs)
        _associations.concat(attrs.map {|a| [:has_many, a] })
        delegate_to_object(*attrs)
      end

      def root_key(key)
        @root_key = key
      end

      def identity_key(id_key)
        @identity_key = id_key
      end

      public

      def _attributes
        @attributes ||= []
      end

      def _associations
        @associations ||= []
      end

      def _root_key
        @root_key ||
          pluralize(underscore(self.name.sub(/Serializer$/, '')))
      end

      def _identity_key
        @identity_key || :id
      end

    end
  end
end
