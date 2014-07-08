module Yaks
  class Runner
    include Util
    include Anima.new(:object, :config, :options)
    include Adamantium
    extend Forwardable

    def_delegators :config, :policy, :default_format, :format_options, :primitivize

    def call
      steps.inject(object) {|memo, (_, step)| step.call(memo) }
    end

    def context
      {
        policy: policy,
        env: env,
        mapper_stack: []
      }.merge(slice_hash(options, :item_mapper))
    end
    memoize :context, freezer: :flat

    def env
      options.fetch(:env, {})
    end
    memoize :env, freezer: :flat

    # @return [Class]
    def format_class
      accept = Rack::Accept::Charset.new(env['HTTP_ACCEPT'])
      mime_type = accept.best_of(Format.mime_types.values)
      return Format.by_mime_type(mime_type) if mime_type
      Format.by_name(options.fetch(:format) { @default_format })
    end

    def steps
      insert_hooks(
        [
          [ :mapper, mapper ],
          [ :format, formatter ],
          [ :primitivize, primitivize],
          [ :serialize, serializer ]
        ]
      )
    end

    def mapper
      options.fetch(:mapper) do
        policy.derive_mapper_from_object(object)
      end.new(context)
    end

    def formatter
      format_class.new(format_options[format_name])
    end

    # @param [Hash] opts
    # @return [String]
    def format_name
      options.fetch(:format) { @default_format }
    end

    def serializer
      ->(x) {x}
    end

    def insert_hooks(steps)
      steps
    end
  end
end
