require 'spec_helper'

describe Yaks::Mapper do
  include_context 'shorthands'

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

  describe 'profile links' do
    before do
      mapper_class.profile :show
    end

    context 'with a dummy registry' do
      it 'should create a link with the profile name as the uri' do
        expect(mapper_class.new(instance).map_links).to eq Yaks::List(resource_link[:profile, 'show'])
      end
    end

    context 'with a registered profile' do
      let(:registry) { Yaks::ProfileRegistry.create { profile :show, 'http://my.api/docs/show' } }

      let(:mapper) { mapper_class.new(instance, profile_registry:registry) }

      it 'should look up and use the correct uri' do
        expect(mapper.map_links).to eq Yaks::List(resource_link[:profile, 'http://my.api/docs/show'])
      end
    end
  end
end
