RSpec.describe Yaks::Primitivize do
  subject(:primitivizer) { described_class.create }

  describe "#initialize" do
    it "should not create any mappings" do
      expect(described_class.new.mappings).to eql Hash[]
    end
  end

  describe '.create' do
    it 'should map String, true, false, nil, numbers to themselves' do
      [
        'hello',
        true,
        false,
        nil,
        100,
        99.99,
        -95.33333
      ].each do |object|
        expect(primitivizer.call(object)).to eql object
      end
    end

    it 'should stringify symbols' do
      expect(primitivizer.call(:foo)).to eql 'foo'
    end

    it 'should recursively handle hashes' do
      expect(primitivizer.call(
          foo: {:wassup => :friends, 123 => '456'}
      )).to eql('foo' => {'wassup' => 'friends', 123 => '456'})
    end

    it 'should handle arrays recursively' do
      expect(primitivizer.call([:foo, [:wassup, :friends], 123, '456']))
        .to eql(['foo', %w[wassup friends], 123, '456'])
    end

    it "should handle URIs by turning them to strings" do
      expect(primitivizer.call(URI("http://foo.bar/baz"))).to eql "http://foo.bar/baz"
    end
  end

  describe '#call' do
    require 'ostruct'

    let(:funny_object) {
      OpenStruct.new('a' => 'b')
    }

    it 'should raise an error when passed an unkown type' do
      def funny_object.inspect
        "I am funny"
      end

      expect { primitivizer.call(funny_object) }
        .to raise_error Yaks::PrimitivizeError, "don't know how to turn OpenStruct (I am funny) into a primitive"
    end

    context 'with custom mapping' do
      require 'matrix'

      let(:primitivizer) do
        described_class.new.tap do |p|
          p.map Vector do |vec|
            vec.map do |i|
              call(i)
            end.to_a
          end

          p.map Symbol do |sym|
            sym.to_s.length
          end
        end
      end

      it 'should evaluate in the context of primitivize' do
        expect(primitivizer.call(Vector[:foo, :baxxx, :bazz])).to eql([3, 5, 4])
      end
    end
  end

  describe "#map" do
    let(:primitivizer) { described_class.new }

    it "should add new mappings" do
      primitivizer.map(String) {|s| s.upcase }
      primitivizer.map(Numeric) {|n| n.next }

      expect(primitivizer.call("foo")).to eql "FOO"
    end
  end
end
