require 'concord'

module Yaks
  module Transform

    class Transitive
      include Concord.new(:a_to_b, :b_to_a)

      def call(input)
        a_to_b.call(input)
      end

      def inverse
        self.class.new(b_to_a, a_to_b)
      end

      def transitive? ; true end
    end

    class WriteObject
      include Concord.new(:klass)

      def call(o)
        o.to_h.tap do |hsh|
          klass.attributes.defaults.each do |key, value|
            hsh.delete(key) if hsh[key] == value
          end
        end
      end

      def inverse ; ReadObject.new(@klass) end
      def transitive? ; true end
    end

    class ReadObject
      include Concord.new(:klass)

      def call(hsh) klass.new(hsh) end
      def inverse ; WriteObject.new(klass) end
      def transitive? ; true end
    end

    class Map
      include Concord.new(:operation)

      def call(array)
        array.map {|obj| operation.call(obj) }
      end

      def inverse
        self.class.new(operation.inverse)
      end

      def transitive? ; true end
    end

    class Array2Hash # Array<Hash> -> Hash<Object, Hash>
      include Concord.new(:key)

      def call(array)
        array.each_with_object({}) do |obj, hsh|
          hsh[obj[key]] = Yaks::Util.slice_hash(obj, *(obj.keys-[key]))
        end
      end

      def inverse
        Hash2Array.new(key)
      end

      def transitive? ; true end
    end

    class Hash2Array # Hash<Object, Hash> -> Array<Hash>
      include Concord.new(:key)

      def call(hash)
        hash.map do |key, value|
          value.merge(key => key)
        end
      end

      def inverse
        Hash2Array.new(key)
      end

      def transitive? ; true end
    end

    class Block
      def initialize(*operations)
        @operations = operations
      end

      def call(object)
        @operations.inject(object) {|memo, op| op.call(memo)}
      end

      def inverse
        self.class.new(*@operations.reverse.map(&:inverse))
      end

      def transitive? ; true end
    end

    class BuildHash
      def initialize(*spec)
        @spec = spec
      end

      def call(input)
        @spec.each_slice(2).with_object({}) do |slice, hsh|
          if slice.length == 1
            hsh.merge!(slice.first.call(input))
          else
            hsh[slice[0]] = slice[1].call(input)
          end
        end
      end

      def transitive? ; true end
    end

    class Identity
      def call(input) input end
      def inverse()   self  end
      def transitive? ; true end
    end

    class Constant
      include Concord.new(:value)
      def call(_) value end
    end

    class Cond
      def initialize(*spec)
        @spec = spec
      end

      def call(input)
        @spec.each_slice(2) do |cond, op|
          return cond.to_proc.call(input) unless op
          return op.call(input) if cond.to_proc.call(input)
        end
      end
    end

    class FetchKey
      include Concord.new(:key)

      def call(input)
        input.fetch(key)
      end

      def inverse
        StoreKey.new(key)
      end

      def transitive? ; true end
    end

    class StoreKey
      include Concord.new(:key)

      def call(input)
        {key => input}
      end

      def inverse
        FetchKey.new(key)
      end

      def transitive? ; true end
    end

    class RejectKeys
      include Concord.new(:keys)

      def call(input)
        Util.slice_hash(input, *(input.keys - keys))
      end
    end
  end
end

if __FILE__ == $0

  require 'yaks'
  require 'rspec/autorun'

  class Apple
    include Yaks::Attributes.new(:type, :weight, quantity: 1)
  end

  RSpec.describe Yaks::Transform::Transitive do
    let(:transform) do
      Yaks::Transform::Transitive.new(
        Yaks::Transform::BuildHash.new(
          '_foo', Yaks::Transform::FetchKey.new(:foo_in),
          '_bar', Yaks::Transform::FetchKey.new(:bar_in),
          Yaks::Transform::FetchKey.new(:attrs)
        ),
        Yaks::Transform::BuildHash.new(
          :foo_in, Yaks::Transform::FetchKey.new('_foo'),
          :bar_in, Yaks::Transform::FetchKey.new('_bar'),
          Yaks::Transform::Block.new(
            Yaks::Transform::RejectKeys.new(%w[_foo _bar]),
            Yaks::Transform::StoreKey.new(:attrs)
          )
        )
      )

    end

    it 'should work' do
      expect(transform.call({foo_in: 'foofoo', bar_in: 'barbar', attrs: {more: :props}})).to eql(
        "_foo"=>"foofoo", "_bar"=>"barbar", more: :props
      )
    end

    it 'should round trip' do
      input = {foo_in: 'foofoo', bar_in: 'barbar', attrs: {more: :props}}
      expect(transform.inverse.call(transform.call(input))).to eql(input)
    end

  end

  RSpec.describe Yaks::Transform::Map do
    let(:apples) {
      [
        Apple.new(type: :boskoop, weight: 100),
        Apple.new(type: :jonagold, weight: 150)
      ]
    }

    it 'should perform the operation for each element' do
      expect(described_class.new(Yaks::Transform::WriteObject.new(Apple)).call(apples)).to eql [
        {type: :boskoop, weight: 100},
        {type: :jonagold, weight: 150}
      ]
    end
  end

  RSpec.describe Yaks::Transform::WriteObject do
    let(:apple) { Apple.new(type: :boskoop, weight: 125, quantity: 2) }
    subject { described_class.new(Apple) }

    it 'turns an object in a Hash' do
      expect(subject.call(apple)).to eql(type: :boskoop, weight: 125, quantity: 2)
    end

    it 'skips defaults' do
      expect(subject.call(apple.quantity(1))).to eql(type: :boskoop, weight: 125)
    end

    it 'round trips' do
      expect(subject.inverse.call(subject.call(apple))).to eql apple
    end

    it 'is transitive' do
      expect(subject).to be_transitive
    end
  end

  RSpec.describe Yaks::Transform::ReadObject do
    let(:apple_attrs) { {type: :boskoop, weight: 125, quantity: 2} }
    subject { described_class.new(Apple) }

    it 'turns a hash into an object' do
      expect(subject.call(apple_attrs)).to eql Apple.new(type: :boskoop, weight: 125, quantity: 2)
    end

    it 'round trips' do
      expect(subject.inverse.call(subject.call(apple_attrs))).to eql apple_attrs
    end
  end

end

# >> .........
# >>
# >> Finished in 0.00329 seconds (files took 0.09738 seconds to load)
# >> 9 examples, 0 failures
