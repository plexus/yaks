module Yaks
  class Config
    class DSL
      # @!attribute [r] config
      #   @return [Yaks::Config]
      attr_reader :config

      # @param [Yaks::Config] config
      # @param [Proc] blk
      # @return [Yaks::Config::DSL]
      def initialize(config, &blk)
        @config       = config
        @policy_class = Class.new(DefaultPolicy)
        @policies     = []
        instance_eval(&blk) if blk
        @policies.each do |policy_blk|
          @policy_class.class_eval &policy_blk
        end
        config.policy_class = @policy_class
      end

      # @param [Symbol] format
      # @return [Symbol]
      def format_options(format, options)
        config.format_options[format] = options
      end

      # @param [Symbol] format
      # @return [Symbol]
      def default_format(format)
        config.default_format = format
      end

      # @param [Object] klass
      # @return [Object]
      def policy(klass)
        @policy_class = klass
      end

      # @param [String] templ
      # @return [String]
      def rel_template(templ)
        config.policy_options[:rel_template] = templ
      end

      # @param [Object] namespace
      # @return [Object]
      def mapper_namespace(namespace)
        config.policy_options[:namespace] = namespace
      end
      alias namespace mapper_namespace

      # @param [Array] args
      # @param [Proc] blk
      # @return [Array]
      def map_to_primitive(*args, &blk)
        config.primitivize.map(*args, &blk)
      end

      # @param [Proc] block
      # @return [Array]
      def after(&block)
        config.steps << block
      end

      # Will define each method available in the DefaultPolicy upon the DSL
      # and then make it available to apply to any Class taking on the
      # `@policies` Array.
      DefaultPolicy.public_instance_methods(false).each do |method|
        define_method method do |&blk|
          @policies << proc {
            define_method method, &blk
          }
        end
      end
    end
  end
end
