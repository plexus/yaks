module Yaks
  class Config
    class DSL
      attr_reader :config

      def initialize(config, &blk)
        @config = config
      end

      def format(fmt)
        config.format = fmt
      end

      def policy(klass = DefaultPolicy, &blk)
        if block_given?
          klass = Class.new(klass, &blk)
        end
        config.policy = klass.new
      end
    end

    attr_accessor :format, :policy

    def initialize(&blk)
      @format = :hal
      @policy = DefaultPolicy.new
      DSL.new(self).instance_eval(&blk)
    end

    def serializer
      Yaks.const_get("#{Util.camelize(format.to_s)}Serializer")
    end

    def serialize(model, opts = {})
      mapper   = opts.fetch(:mapper) { policy.derive_mapper_from_model(model) }
      resource = mapper.new(model, policy).to_resource
      serializer.new(resource).serialize
    end
  end
end
