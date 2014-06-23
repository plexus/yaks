require 'spec_helper'

RSpec.describe Yaks::Primitivize do
  subject(:primitivizer) { described_class.create }

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
          :foo => {:wassup => :friends, 123 => '456'}
      )).to eql('foo' => {'wassup' => 'friends', 123 => '456'})
    end

    it 'should handle arrays recursively' do
      expect(primitivizer.call(
          [:foo, [:wassup, :friends], 123, '456']
      )).to eql( ['foo', ['wassup', 'friends'], 123, '456'] )
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

      expect { primitivizer.call(funny_object) }.to raise_error "don't know how to turn OpenStruct (I am funny) into a primitive"
    end

    context 'with custom mapping' do
      let(:primitivizer) do
        described_class.new.tap do |p|
          p.map OpenStruct do |os|
            os.each_pair.with_object({}) do |(k,v), hsh|
              hsh[call(k)] = call(v)
            end
          end

          p.map Symbol do |sym|
            sym.to_s.length
          end
        end
      end

      it 'should evaluate in the context of primitivize' do
        expect( primitivizer.call(OpenStruct.new(:foo => :bars)) ).to eql( 3 => 4 )
      end
    end


  end
end
