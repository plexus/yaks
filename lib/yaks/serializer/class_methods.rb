# -*- coding: utf-8 -*-

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
        attrs.reject(& μ(:method_defined?) ).each(& μ(:def_delegator).(:object) )
      end

      def attributes(*attrs)
        _attributes.concat attrs
        delegate_to_object(*attrs)
      end

      def has_one(*attrs)
        attrs, opts = extract_options(attrs)
        _associations.concat(attrs.map {|a| Association.new(a, true, opts) })
        delegate_to_object(*attrs)
      end

      def has_many(*attrs)
        attrs, opts = extract_options(attrs)
        _associations.concat(attrs.map {|a| Association.new(a, false, opts) })
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
