module Yaks
  class Primitivize
    attr_reader :mappings

    def initialize
      @mappings = {}
    end

    def call(object, _env = nil)
      if object.is_a?(String) || object.is_a?(Numeric) || [true, false, nil].include?(object)
        return object
      end

      mappings.each do |pattern, block|
        # rubocop:disable Style/CaseEquality
        if pattern === object
          return block.call(object, self)
        end
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
        p.map Symbol, URI do |object, _|
          object.to_s
        end

        p.map Hash do |object, recurse|
          object.to_enum.with_object({}) do |(key, value), output|
            output[recurse.call(key)] = recurse.call(value)
          end
        end

        p.map Enumerable do |object, recurse|
          object.map(&recurse.method(:call))
        end
      end
    end
  end
end
