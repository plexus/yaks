module Yaks
  class Config
    include Yaks::FP::Callable

    # @!attribute [r] format_options
    #   @return [Hash<Symbol,Hash>]
    attr_reader :format_options

    # @!attribute [rw] default_format
    #   @return [Symbol]
    attr_accessor :default_format

    # @!attribute [rw] policy_class
    #   @return [Class]
    attr_accessor :policy_class

    # @!attribute [r] policy_options
    #   @return [Hash]
    attr_reader :policy_options

    # @!attribute [rw] primitivize
    #   @return [Primitivize]
    attr_accessor :primitivize

    # @!attribute [r] serializers
    #   @return [Hash<Symbol,#call>]
    attr_reader :serializers

    # @!attribute [r] hooks
    #   @return [Array]
    attr_reader :hooks

    # @param blk [Proc] Configuration block
    def initialize(&blk)
      @format_options = Hash.new({})
      @default_format = :hal
      @policy_options = {}
      @primitivize    = Primitivize.create
      @serializers    = Serializer.all.dup
      @hooks          = []

      DSL.new(self, &blk)
    end

    # @return [Yaks::DefaultPolicy]
    def policy
      @policy ||= @policy_class.new(@policy_options)
    end

    def runner(object, options)
      Runner.new(config: self, object: object, options: options)
    end

    # Main entry point into yaks
    #
    # @param object [Object] The object to serialize
    # @param options [Hash<Symbol,Object>] Serialization options
    #
    # @option env [Hash] The rack environment
    # @option format [Symbol] The target format, default :hal
    # @option mapper [Class] Mapper class to use
    # @option item_mapper [Class] Mapper class to use for items in a top-level collection
    #
    def call(object, options = {})
      runner(object, options).call
    end
    alias serialize call

    def map(object, options = {})
      runner(object, options).map(object)
    end
  end
end
