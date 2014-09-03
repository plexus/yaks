module Yaks
  class Config

    # @!attribute [rw] format_options
    #   @return [Hash]
    # @!attribute [rw] default_format
    #   @return [Symbol]
    # @!attribute [rw] policy_class
    #   @return [Constant]
    # @!attribute [rw] policy_options
    #   @return [Hash]
    # @!attribute [rw] primitivize
    #   @return [Boolean]
    # @!attribute [rw] steps
    #   @return [Array]
    attr_accessor :format_options, :default_format, :policy_class, :policy_options, :primitivize, :steps

    # @param [Proc] blk
    # @return [Yaks::Config::DSL]
    def initialize(&blk)
      @format_options = Hash.new({})
      @default_format = :hal
      @policy_options = {}
      @primitivize    = Primitivize.create
      @serializers    = {}
      @steps          = [ @primitivize ]

      DSL.new(self, &blk)
    end

    # @return [Yaks::DefaultPolicy, Object]
    def policy
      @policy_class.new(@policy_options)
    end

    # model                => Yaks::Resource
    # Yaks::Resource       => serialized structure
    # serialized structure => serialized flat
    def call(object, options = {})
      Runner.new(config: self, object: object, options: options).call
    end
    alias serialize call
  end
end
