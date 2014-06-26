module Yaks
  class Config
    class DSL
      attr_reader :config

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

      def format_options(format, options)
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

      def mapper_namespace(namespace)
        config.policy_options[:namespace] = namespace
      end
      alias namespace mapper_namespace

      def map_to_primitive(*args, &blk)
        config.primitivize.map(*args, &blk)
      end

      def after(&block)
        config.steps << block
      end

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
