module Yaks
  class Config

    # @!attribute [rw] format_options
    #   @return [Hash<Symbol,Hash>]
    # @!attribute [rw] default_format
    #   @return [Symbol]
    # @!attribute [rw] policy_class
    #   @return [Class]
    # @!attribute [rw] policy_options
    #   @return [Hash]
    # @!attribute [rw] primitivize
    #   @return [Primitivize]
    # @!attribute [rw] serializers
    #   @return [Hash<Symbol,#call>]
    # @!attribute [rw] steps
    #   @return [Array<#call>]
    attr_accessor :format_options, :default_format, :policy_class, :policy_options, :primitivize, :steps, :serializers

    # @param [Proc] blk
    def initialize(&blk)
      @format_options = Hash.new({})
      @default_format = :hal
      @policy_options = {}
      @primitivize    = Primitivize.create
      @serializers    = {}
      @steps          = [ @primitivize ]

      DSL.new(self, &blk)
    end

    # @return [Yaks::DefaultPolicy]
    def policy
      @policy_class.new(@policy_options)
    end

    # @param object [Object] The object to serialize
    # @param options [Hash<Symbol,Object>] Serialization options
    # @option format [Symbol] The target format, default :hal
    # @option mapper [Class] Mapper class to use
    # @option item_mapper [Class] Mapper class to use for items in a top-level collection
    def call(object, options = {})
      Runner.new(config: self, object: object, options: options).call
    end
    alias serialize call
  end
end
