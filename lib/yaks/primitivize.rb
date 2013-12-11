module Yaks
  class Primitivize
    include Concord.new(:object)

    def self.call(object)
      new(object).call
    end

    def call
      case object
      when String, TrueClass, FalseClass, NilClass, Numeric
        object
      when Symbol
        object.to_s
      when Hash, Hamster::Hash
        object.to_enum(:each).with_object({}) do |(key, value), output|
          output[self.class.(key)] = self.class.(value)
        end
      when Enumerable, Hamster::Enumerable
        object.map(&self.class.method(:call)).to_a
      else
        raise "don't know how to turn #{object.class} (#{object.inspect}) into a primitive"
      end
    end
  end
end
