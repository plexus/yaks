module Yaks
  class Config
    class DSL
      # @!attribute [r] config
      #   @return [Yaks::Config]
      attr_reader :config

      # @param [Yaks::Config] config
      # @param [Proc] block
      def initialize(config, &block)
        @config       = config
        @policy_class = Class.new(DefaultPolicy)
        @policies     = []
        instance_eval(&block) if block
        @policies.each do |policy_block|
          @policy_class.class_eval &policy_block
        end
        config.policy_class = @policy_class
      end

      # Set the options for a format
      #
      # @param [Symbol] format
      # @param [Hash] options
      #
      # @example
      #
      #   yaks = Yaks.new do
      #     format_options :hal, {plural_links: [:related_content]}
      #   end
      def format_options(format, options)
        config.format_options[format] = options
      end

      # Set the default format
      #
      # Defaults to +:hal+
      #
      # @param [Symbol] format
      #   Format identifier, one of +Yaks::Format.names+
      #
      # @example
      #
      #    yaks = Yaks.new do
      #      default_fomat :json_api
      #    end
      #
      def default_format(format)
        config.default_format = format
      end

      # Configure JSON serializer
      #
      # Defaults to JSON.pretty_generate
      #
      # @example
      #
      #   yaks = Yaks.new do
      #     json_serializer &Oj.method(:dump)
      #   end
      #
      # @param [Proc] block
      #   Serialization procedure
      def json_serializer(&block)
        config.serializers[:json] = block
      end

      %w[before after around skip].map(&:intern).each do |hook_type|
        define_method hook_type do |step, name = :"#{hook_type}_#{step}", &block|
          config.hooks << [hook_type, step, name, block]
        end
      end

      # @param [Object] klass
      def policy(klass)
        @policy_class = klass
      end

      # @param [String] template
      # @return [String]
      def rel_template(template)
        config.policy_options[:rel_template] = template
      end

      # @param [Object] namespace
      # @return [Object]
      def mapper_namespace(namespace)
        config.policy_options[:namespace] = namespace
      end
      alias namespace mapper_namespace

      # @param [Array] args
      # @param [Proc] block
      # @return [Array]
      def map_to_primitive(*args, &block)
        config.primitivize.map(*args, &block)
      end

      # Will define each method available in the DefaultPolicy upon the DSL
      # and then make it available to apply to any Class taking on the
      # `@policies` Array.
      DefaultPolicy.public_instance_methods(false).each do |method|
        define_method method do |&block|
          @policies << proc {
            define_method method, &block
          }
        end
      end
    end
  end
end
