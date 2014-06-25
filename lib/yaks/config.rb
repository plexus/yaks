module Yaks
  class Config
    attr_accessor :format_options, :default_format, :policy_class, :policy_options, :primitivize, :steps

    def initialize(&blk)
      @format_options = Hash.new({})
      @default_format = :hal
      @policy_options = {}
      @primitivize    = Primitivize.create
      @steps          = [ @primitivize ]
      DSL.new(self, &blk)
    end

    def policy
      @policy_class.new(@policy_options)
    end

    def serializer_class(opts, env)
      if env.key? 'HTTP_ACCEPT'
        accept = Rack::Accept::Charset.new(env['HTTP_ACCEPT'])
        mime_type = accept.best_of(Serializer.mime_types.values)
        return Serializer.by_mime_type(mime_type) if mime_type
      end
      Serializer.by_name(opts.fetch(:format) { @default_format })
    end

    def format_name(opts)
      opts.fetch(:format) { @default_format }
    end

    def options_for_format(format)
      format_options[format]
    end

    # model                => Yaks::Resource
    # Yaks::Resource       => serialized structure
    # serialized structure => serialized flat

    def call(object, opts = {})
      env = opts.fetch(:env, {})
      context = {
        policy: policy,
        env: env,
        mapper_stack: []
      }

      mapper     = opts.fetch(:mapper) { policy.derive_mapper_from_object(object) }.new(context)
      serializer = serializer_class(opts, env).new(format_options[format_name(opts)])

      [ mapper, serializer, *steps ].inject(object) {|memo, step| step.call(memo) }
    end
    alias serialize call
  end
end
