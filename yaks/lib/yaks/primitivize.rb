module Yaks
  class Primitivize

    attr_reader :mappings

    def initialize
      @mappings = {}
    end

    def call(object)
      mappings.each do |pattern, block|
        return instance_exec(object, &block) if pattern === object
      end
      raise PrimitivizeError, "don't know how to turn #{object.class} (#{object.inspect}) into a primitive"
    end

    def map(*types, &blk)
      types.each do |type|
        mappings[type] = blk
      end
    end

    def self.create
      new.tap do |p|
        p.map String, Numeric, true, false, nil do |object|
          object
        end

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
