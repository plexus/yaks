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
      #
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

      # Configure serializer for specific output format, e.g. JSON
      #
      # This will override the default registered serializer. Note
      # that extension gems can register their own serializers, see
      # Yaks::Serializer.register
      #
      # @example
      #
      #   yaks = Yaks.new do
      #     serializer :json, &Oj.method(:dump)
      #   end
      #
      # @type [Symbol] type
      #   Output format
      # @param [Proc] serializer
      #   Serialization procedure
      #
      def serializer(type, &serializer)
        config.serializers[type] = serializer
      end

      # @deprecated
      def json_serializer(&serializer)
        serializer(:json, &serializer)
      end

      %w[before after around skip].map(&:intern).each do |hook_type|
        define_method hook_type do |step, name = :"#{hook_type}_#{step}", &block|
          config.hooks << [hook_type, step, name, block]
        end
      end

      # Set a different policy implementation
      #
      # By default Yaks uses +Yaks::DefaultPolicy+ to derive missing
      # information. You can swap in a class with a compatible
      # interface to change the default behavior
      #
      # To override a single policy method, simply call a method with
      # the same name as part of your Yaks configuration, passing a
      # block to define the new behavior.
      #
      # @example
      #
      #    yaks = Yaks.new do
      #      derive_type_from_mapper_class do |mapper_class|
      #        mapper_class.name.sub(/Mapper^/,'')
      #      end
      #    end
      #
      # @param [Class] klass
      #   Policy class
      #
      def policy(klass)
        @policy_class = klass
      end

      # Set the template for deriving rels
      #
      # Used to derive rels for links and subresources.
      #
      # @example
      #
      #   yaks = Yaks.new do
      #     rel_template 'http://api.example.com/rels/{rel}'
      #   end
      #
      # @param [String] template
      #   A valid URI template containing +{rel}+
      #
      def rel_template(template)
        config.policy_options[:rel_template] = template
      end

      # Set the namespace (Ruby module) that contains your mappers
      #
      # When your mappers don't live at the top-level, then set this
      # so Yaks can correctly infer the mapper class from the model
      # class.
      #
      # @example
      #
      #   yaks = Yaks.new do
      #     mapper_namespace API::Mappers
      #   end
      #
      #   module API::Mappers
      #     class FruitMapper < Yaks::Mapper
      #        ...
      #     end
      #   end
      #
      #   class Fruit < BaseModel
      #     ...
      #   end
      #
      # @param [Module] namespace
      #
      def mapper_namespace(namespace)
        config.policy_options[:namespace] = namespace
      end
      alias namespace mapper_namespace

      # @param [Array] args
      # @param [Proc] block
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
