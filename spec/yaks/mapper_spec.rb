require 'spec_helper'

describe Yaks::Mapper do
  let(:mapper_class) { Class.new(Yaks::Mapper) }
  let(:model)        { Struct.new(:foo, :bar) }
  let(:instance)     { model.new('hello', 'world') }

  context 'with attributes' do
    before do
      mapper_class.attributes :foo, :bar
    end

    it 'should make the configured attributes available on the instance' do
      expect(mapper_class.new(Object.new).attributes).to eq Yaks::List(:foo, :bar)
    end

    describe 'mapping attributes' do
      it 'should load them from the model' do
        expect(mapper_class.new(instance).map_attributes).to eq Yaks::List([:foo, 'hello'], [:bar, 'world'])
      end
    end
  end
end
