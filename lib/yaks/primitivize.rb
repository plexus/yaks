module Yaks
  class Primitivize
    def self.call(object)
      new.call(object)
    end

    def call(object)
      case object
      when String, TrueClass, FalseClass, NilClass, Numeric
        object
      when Symbol
        object.to_s
      when Hash, Hamster::Hash
        object.to_enum(:each).with_object({}) do |(key, value), output|
          output[self.(key)] = self.(value)
        end
      when Enumerable, Hamster::Enumerable
        object.map(&method(:call)).to_a
      else
        raise "don't know how to turn #{object.class} (#{object.inspect}) into a primitive"
      end
    end
  end
end
