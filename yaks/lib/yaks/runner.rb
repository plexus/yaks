module Yaks
  class Runner
    include Util
    include Anima.new(:object, :config, :options)
    include Adamantium::Flat
    extend Forwardable

    def_delegators :config,        :policy, :default_format, :format_options_hash,
                                   :primitivize, :serializers
    def_delegators :format_class,  :media_type, :format_name

    def call
      Pipeline.new(steps).insert_hooks(hooks).call(object, env)
    end

    def read
      Pipeline.new([[:parse, serializer.inverse], [:format, formatter.inverse]]).insert_hooks(hooks).call(object, env)
    end

    def map
      Pipeline.new([[:map, mapper]]).insert_hooks(hooks).call(object, env)
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
    memoize :env, freezer: :noop

    # @return [Class]
    def format_class
      Format.by_accept_header(env['HTTP_ACCEPT']) {
        Format.by_name(options.fetch(:format) { default_format })
      }
    end
    memoize :format_class, freezer: :noop

    def steps
      [[ :map, mapper ],
       [ :format, formatter ],
       [ :primitivize, primitivizer],
       [ :serialize, serializer ]]
    end
    memoize :steps

    def mapper
      options.fetch(:mapper) do
        policy.derive_mapper_from_object(object)
      end.new(context)
    end
    memoize :mapper, freezer: :noop

    def formatter
      format_class.new(format_options_hash[format_name])
    end
    memoize :formatter, freezer: :noop

    def primitivizer
      proc do |input|
        if format_class.serializer.equal? :json
          primitivize.call(input)
        else
          input
        end
      end
    end
    memoize :primitivizer

    def serializer
      serializers.fetch(format_class.serializer)
    end
    memoize :serializer, freezer: :noop

    def hooks
      config.hooks + options.fetch(:hooks, [])
    end
  end
end
