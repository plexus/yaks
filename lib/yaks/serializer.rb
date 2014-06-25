module Yaks
  class Serializer
    extend Forwardable
    include Util

    attr_reader :options
    def_delegators :resource, :links, :attributes, :subresources

    protected :links, :attributes, :subresources, :options

    def initialize(options = {})
      @options = options
    end

    def call(resource)
      serialize_resource(resource)
    end
    alias serialize call

    class << self
      def register(klass, name, mime_type)
        @serializers ||= {}
        @serializers[name] = klass

        @mime_types  ||= {}
        @mime_types[mime_type] = [name, klass]
      end

      def by_name(name)
        @serializers.fetch(name)
      end

      def by_mime_type(mime_type)
        @mime_types.fetch(mime_type)[1]
      end

      def mime_types
        @mime_types.inject({}) {|memo, (mime_type, (name, _))| memo[name] = mime_type ; memo }
      end
    end
  end
end
