module Yaks
  class Pipeline
    include Util, Serializer::Lookup

    attr_reader :objects, :serializer_lookup, :fold, :options, :steps

    def initialize(objects, options = {})
      @objects           = objects
      @serializer_lookup = options.fetch(:serializer_lookup) { Yaks.default_serializer_lookup }
      format             = options.fetch(:format) { :json_api }
      @fold              = Yaks.const_get("Fold#{camelize(format.to_s)}") if format.is_a?(Symbol)
      @options           = options
      @steps             = options.fetch(:steps) { [CollectionSerializer, fold, Primitivize] }
      @steps            += options.fetch(:extra_steps) { [] }
    end

    def call
      steps.reduce(objects) do |memo, step|
        case step.method(:call).arity
        when 1, -1
          step.call(memo)
        when 2, -2
          step.call(memo, options)
        else
          raise "pipeline step #{step} must take one or two arguments"
        end
      end
    end

  end
end
