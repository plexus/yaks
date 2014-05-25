module Yaks
  class Primitivize
    include Concord.new(:object)

    # TODO Global config, make this extensible in a per-instance way
    MAPPINGS = {}

    def self.call(object)
      new(object).call
    end

    def self.map(*types, &blk)
      types.each do |type|
        MAPPINGS[type] = blk
      end
    end

    map String, TrueClass, FalseClass, NilClass, Numeric do
      object
    end

    map Symbol do
      object.to_s
    end

    map Hash do
      object.to_enum(:each).with_object({}) do |(key, value), output|
        output[self.class.(key)] = self.class.(value)
      end
    end

    map Enumerable do
      object.map(&self.class.method(:call)).to_a
    end

    def call
      MAPPINGS.each do |pattern, block|
        return instance_eval(&block) if pattern === object
      end
      raise "don't know how to turn #{object.class} (#{object.inspect}) into a primitive"
    end
  end
end
