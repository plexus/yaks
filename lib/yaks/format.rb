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
      attr_reader :name, :serializer, :mime_type

      def all
        @formats ||= []
      end

      # @param [Constant] klass
      # @param [Symbol] format_name
      # @param [String] mime_type
      # @return [Array]
      def register(name, serializer, mime_type)
        @name = name
        @serializer = serializer
        @mime_type = mime_type

        Format.all << self
      end

      # @param [Symbol] format_name
      # @return [Constant]
      # @raise [KeyError]
      def by_name(name)
        find(:name, name)
      end

      # @param [Symbol] mime_type
      # @return [Constant]
      # @raise [KeyError]
      def by_mime_type(mime_type)
        find(:mime_type, mime_type)
      end

      def by_accept_header(accept_header)
        mime_type = Rack::Accept::Charset.new(accept_header).best_of(mime_types.values)
        if mime_type
          by_mime_type(mime_type)
        else
          yield if block_given?
        end
      end

      def mime_types
        Format.all.each_with_object({}) do
          |format, memo| memo[format.name] = format.mime_type
        end
      end

      def names
        mime_types.keys
      end

      private

      def find(key, cond)
        Format.all.detect {|format| format.send(key) == cond }
      end
    end
  end
end
