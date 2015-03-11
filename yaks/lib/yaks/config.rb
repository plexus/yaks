module Yaks
  class Config
    extend Yaks::Util::Deprecated
    include Yaks::FP::Callable,
            Attributes.new(
              format_options_hash: Hash.new({}),
              default_format: :hal,
              policy_options: {},
              policy_class: DefaultPolicy,
              primitivize: Primitivize.create,
              serializers: Serializer.all,
              hooks: []
            )

    class << self
      alias create new
    end

    deprecated_alias :namespace, :mapper_namespace

    def format_options(format, options = Undefined)
      with(format_options_hash: format_options_hash.merge(format => options))
    end

    def serializer(type, &serializer)
      with(serializers: serializers.merge(type => serializer))
    end

    def json_serializer(&serializer)
      with(serializer: :json, &serializer)
    end

    %w[before after around skip].map(&:intern).each do |hook_type|
      define_method hook_type do |step, name = :"#{hook_type}_#{step}", &block|
        append_to(:hooks, [hook_type, step, name, block])
      end
    end

    def rel_template(template)
      with(policy_options: policy_options.merge(:rel_template => template))
    end

    def mapper_namespace(namespace)
      with(policy_options: policy_options.merge(:namespace => namespace))
    end

    def map_to_primitive(*args, &block)
      with(primitivize: primitivize.dup.tap { |prim| prim.map(*args, &block) })
    end

    DefaultPolicy.public_instance_methods(false).each do |method|
      define_method method do |&block|
        with(
          policy_class: Class.new(policy_class) do
            define_method method, &block
          end
        )
      end
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
      runner(object, options).map
    end

    def read(data, options = {})
      runner(data, options).read
    end
  end
end
