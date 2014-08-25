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
      @steps          = [
        @primitivize
      ]
      DSL.new(self, &blk)
    end

    # @return [Yaks::DefaultPolicy, Object]
    def policy
      @policy_class.new(@policy_options)
    end

    # @param [Hash] opts
    # @param [Hash] env
    # @return [Yaks::Format::CollectionJson, Yaks::Format::Hal, Yaks::Format::JsonApi]
    def format_class(opts, env)
      accept = Rack::Accept::Charset.new(env['HTTP_ACCEPT'])
      mime_type = accept.best_of(Format.mime_types.values)
      return Format.by_mime_type(mime_type) if mime_type
      Format.by_name(opts.fetch(:format) { @default_format })
    end

    # @param [Hash] opts
    # @return [String]
    def format_name(opts)
      opts.fetch(:format) { @default_format }
    end

    # @param [Symbol] format
    # @return [Object]
    def options_for_format(format)
      format_options[format]
    end

    # model                => Yaks::Resource
    # Yaks::Resource       => serialized structure
    # serialized structure => serialized flat
    #
    # @param [Object] object
    # @param [Hash] opts
    # @return [Object]
    def call(object, opts = {})
      env = opts.fetch(:env, {})
      context = {
        policy: policy,
        env: env,
        mapper_stack: []
      }

      mapper = opts.fetch(:mapper) { policy.derive_mapper_from_object(object) }.new(context)
      format = format_class(opts, env).new(format_options[format_name(opts)])

      [ mapper, format, *steps ].inject(object) {|memo, step| step.call(memo) }
    end
    alias serialize call
  end
end
