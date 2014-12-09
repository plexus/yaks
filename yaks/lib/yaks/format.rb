module Yaks
  class Format
    extend Forwardable
    include Util
    include FP::Callable

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
    def call(resource, _env = {})
      serialize_resource(resource)
    end
    alias serialize call

    class << self
      attr_reader :format_name, :serializer, :media_type

      deprecated_alias :mime_type, :media_type

      def all
        @formats ||= []
      end

      # @param [Constant] klass
      # @param [Symbol] format_name
      # @param [String] media_type
      # @return [Array]
      def register(format_name, serializer, media_type)
        @format_name = format_name
        @serializer = serializer
        @media_type = media_type

        Format.all << self
      end

      # @param [Symbol] format_name
      # @return [Constant]
      # @raise [KeyError]
      def by_name(format_name)
        find(:format_name, format_name)
      end

      # @param [Symbol] media_type
      # @return [Constant]
      # @raise [KeyError]
      def by_media_type(media_type)
        find(:media_type, media_type)
      end
      deprecated_alias :by_mime_type, :by_media_type

      def by_accept_header(accept_header)
        media_type = Rack::Accept::Charset.new(accept_header).best_of(media_types.values)
        if media_type
          by_media_type(media_type)
        else
          yield if block_given?
        end
      end

      def media_types
        Format.all.each_with_object({}) do
          |format, memo| memo[format.format_name] = format.media_type
        end
      end
      deprecated_alias :mime_types, :media_types

      def names
        media_types.keys
      end

      private

      def find(key, cond)
        Format.all.detect {|format| format.send(key) == cond }
      end
    end
  end
end
