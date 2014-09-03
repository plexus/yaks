module Yaks
  class Format
    extend Forwardable
    include Util

    # @!attribute [r] options
    #   @return [Hash]
    attr_reader :options

    def_delegators :resource, :links, :attributes, :subresources

    protected :links, :attributes, :subresources, :options

    # @param [Hash] options
    # @return [Hash]
    def initialize(options = {})
      @options = options
    end

    # @param [Yaks::Resource] resource
    # @return [Hash]
    def call(resource)
      serialize_resource(resource)
    end
    alias serialize call

    class << self
      # @param [Constant] klass
      # @param [Symbol] name
      # @param [String] mime_type
      # @return [Array]
      def register(klass, name, mime_type)
        @formats ||= {}
        @formats[name] = klass

        @mime_types  ||= {}
        @mime_types[mime_type] = [name, klass]
      end

      # @param [Symbol] name
      # @return [Constant]
      # @raise [KeyError]
      def by_name(name)
        @formats.fetch(name)
      end

      # @param [Symbol] mime_type
      # @return [Constant]
      # @raise [KeyError]
      def by_mime_type(mime_type)
        @mime_types.fetch(mime_type)[1]
      end

      # @return [Hash]
      def mime_types
        @mime_types.inject({}) {|memo, (mime_type, (name, _))| memo[name] = mime_type ; memo }
      end

      def names
        mime_types.keys
      end
    end
  end
end
