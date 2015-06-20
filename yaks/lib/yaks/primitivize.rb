module Yaks
  class Primitivize
    attr_reader :mappings

    def initialize
      @mappings = {}
    end

    def call(object)
      if object.is_a?(String) || object.is_a?(Numeric) || [true, false, nil].include?(object)
        return object
      end

      mappings.each do |pattern, block|
        # rubocop:disable Style/CaseEquality
        return instance_exec(object, &block) if pattern === object
      end
      raise PrimitivizeError, "don't know how to turn #{object.class} (#{object.inspect}) into a primitive"
    end

    def map(*types, &block)
      types.each do |type|
        @mappings = mappings.merge(type => block)
      end
    end

    def self.create
      new.tap do |p|
        p.map Symbol, URI do |object|
          object.to_s
        end

        p.map Hash do |object|
          object.to_enum.with_object({}) do |(key, value), output|
            output[call(key)] = call(value)
          end
        end

        p.map Enumerable do |object|
          object.map(&method(:call))
        end
      end
    end
  end
end
