module Yaks
  class Serializer
    extend Forwardable
    include Util

    attr_reader :resource, :options
    def_delegators :resource, :links, :attributes, :subresources

    protected :resource, :links, :attributes, :subresources, :options

    def initialize(resource, options = {})
      @resource = resource
      @options  = YAKS_DEFAULT_OPTIONS.merge(options)
    end

    def call
      serialize_resource(resource)
    end
    alias serialize call

    class << self
      def register(klass, name, mime_type)
        @serializers ||= {}
        @serializers[name] = klass

        @mime_types  ||= {}
        @mime_types[mime_type] = klass
      end

      def by_name(name)
        @serializers.fetch(name)
      end

      def by_mime_type(mime_type)
        @mime_types.fetch(mime_type)
      end

      def mime_types
        @mime_types.keys
      end
    end
  end
end
