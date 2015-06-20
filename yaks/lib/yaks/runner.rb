module Yaks
  class Runner
    include Util
    include Anima.new(:object, :config, :options)
    extend Forwardable

    def_delegators :config,        :policy, :default_format, :format_options_hash,
                                   :primitivize, :serializers
    def_delegators :format_class,  :media_type, :format_name

    def call
      Pipeline.new(steps).insert_hooks(hooks).call(object, env)
    end

    def read
      Pipeline.new([[:parse, serializer.inverse], [:read, formatter.inverse]]).insert_hooks(hooks).call(object, env)
    end

    def format
      Pipeline.new([[:format, formatter], [:primitivize, primitivizer]]).insert_hooks(hooks).call(object, env)
    end

    def map
      Pipeline.new([[:map, mapper]]).insert_hooks(hooks).call(object, env)
    end

    def context
      @context ||= {
        policy: policy,
        env: env,
        mapper_stack: []
      }.merge(slice_hash(options, :item_mapper))
    end

    def env
      @env ||= options.fetch(:env, {})
    end

    # @return [Class]
    def format_class
      @format_class ||= Format.by_accept_header(env['HTTP_ACCEPT']) {
        Format.by_name(options.fetch(:format) { default_format })
      }
    end

    def steps
      @steps ||= [
        [ :map, mapper ],
        [ :format, formatter ],
        [ :primitivize, primitivizer],
        [ :serialize, serializer ]
      ]
    end

    def mapper
      @mapper ||= options.fetch(:mapper) do
        policy.derive_mapper_from_object(object)
      end.new(context)
    end

    def formatter
      @formatter ||= format_class.new(format_options_hash[format_name])
    end

    def primitivizer
      @primitivizer ||=
        if format_class.serializer.equal? :json
          primitivize.method(:call)
        else
          ->(x) { x }
        end
    end

    def serializer
      @serializer ||= serializers.fetch(format_class.serializer)
    end

    def hooks
      config.hooks + options.fetch(:hooks, [])
    end
  end
end
