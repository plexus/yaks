module Yaks
  class Config
    class DSL
      attr_reader :config

      def initialize(config, &blk)
        @config = config
        @policy_class = Class.new(DefaultPolicy)
        @policies     = []
        instance_eval(&blk) if blk
        @policies.each do |policy_blk|
          @policy_class.class_eval &policy_blk
        end
        config.policy_class = @policy_class
      end

      def format(format, options)
        config.format_options[format] = options
      end

      def default_format(format)
        config.default_format = format
      end

      def policy(klass)
        @policy_class = klass
      end

      def rel_template(templ)
        config.policy_options[:rel_template] = templ
      end

      DefaultPolicy.public_instance_methods(false).each do |method|
        define_method method do |&blk|
          @policies << proc {
            define_method method, &blk
          }
        end
      end
    end

    attr_accessor :format_options, :default_format, :policy_class, :policy_options

    def initialize(&blk)
      @format_options = Hash.new({})
      @default_format = :hal
      @policy_options = {}
      DSL.new(self, &blk)
    end

    def policy
      @policy_class.new(@policy_options)
    end

    def serializer_class(format)
      Yaks.const_get("#{Util.camelize(format.to_s)}Serializer")
    end

    def options_for_format(format)
      format_options[format]
    end

    def serialize(model, opts = {})
      mapper     = opts.fetch(:mapper) { policy.derive_mapper_from_model(model) }
      resource   = mapper.new(model, policy).to_resource
      format     = opts.fetch(:format) { @default_format }
      serialized = serializer_class(format).new(resource, format_options[format]).call
      Primitivize.call(serialized)
    end
  end
end
