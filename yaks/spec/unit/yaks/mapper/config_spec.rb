require 'spec_helper'

RSpec.describe Yaks::Mapper::Config do
  Undefined = Yaks::Undefined

  subject(:config) { described_class.new }

  describe '#initialize' do
    subject(:config) do
      described_class.new(
        type:         'foo',
        attributes:   [:a],
        links:        [:b],
        associations: [:c]
      )
    end


    its(:type)         { should eql 'foo' }
    its(:attributes)   { should eql [:a] }
    its(:links)        { should eql [:b] }
    its(:associations) { should eql [:c] }
  end

  describe '#attributes' do
    context 'an empty config' do
      it 'should return an empty attributes list' do
        expect(config.attributes).to eq []
      end
    end

    it 'should add attributes' do
      expect(config.attributes(:foo, :bar, :baz).attributes).to eq [
        Yaks::Mapper::Attribute.new(:foo),
        Yaks::Mapper::Attribute.new(:bar),
        Yaks::Mapper::Attribute.new(:baz)
      ]
    end

    it 'should be chainable' do
      expect(
        config
          .attributes(:foo, :bar)
          .attributes(:baz)
          .attributes
      ).to eq [
        Yaks::Mapper::Attribute.new(:foo),
        Yaks::Mapper::Attribute.new(:bar),
        Yaks::Mapper::Attribute.new(:baz)
      ]
    end
  end

  describe '#links' do
    context 'an empty config' do
      it 'should have an empty link list' do
        expect(config.links).to eq []
      end
    end

    describe 'adding links' do
      let(:config) {
        subject
          .link(:self, '/foo/bar/{id}')
          .link(:profile, '/profile/foo')
      }

      it 'should have the links in the link list' do
        expect(config.links).to include Yaks::Mapper::Link.new(:profile, '/profile/foo', {})
        expect(config.links).to include Yaks::Mapper::Link.new(:self, '/foo/bar/{id}', {})
      end
    end

    describe 'links with the same rel' do
      let(:config) {
        subject
          .link(:self, '/foo/self')
          .link(:self, '/foo/me')
      }

      it 'should have the links in the defined order' do
        expect(config.links).to eql [
          Yaks::Mapper::Link.new(:self, '/foo/self', {}),
          Yaks::Mapper::Link.new(:self, '/foo/me', {})
        ]
      end
    end
  end

  describe '#has_one' do
    context 'with a mapper specified' do
      let(:config) { subject.has_one :mother, mapper: Yaks::Mapper }

      it 'should have the association configured' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasOne.new(name: :mother, child_mapper: Yaks::Mapper)
        ]
      end
    end

    context 'with no options' do
      let(:config) { subject.has_one :mother }

      it 'should have undefined mapper, rel, collection_mapper' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasOne.new(name: :mother)
        ]
      end
    end

    context 'with a rel specified' do
      let(:config) { subject.has_one :mother, rel: '/api/rels/mother' }

      it 'should have the rel' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasOne.new(name: :mother, rel: '/api/rels/mother')
        ]
      end

    end
  end

  describe '#has_many' do
    context 'with a mapper specified' do
      let(:config) { subject.has_many :shoes, mapper: Yaks::Mapper }

      it 'should have the association configured' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasMany.new(name: :shoes, child_mapper: Yaks::Mapper)
        ]
      end
    end

    context 'with no options' do
      let(:config) { subject.has_many :shoes }

      it 'should have undefined mapper, rel, collection_mapper' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasMany.new(name: :shoes)
        ]
      end
    end

    context 'with a collection mapper set' do
      let(:config) { subject.has_many :shoes, collection_mapper: :a_collection_mapper }

      it 'should have the association configured' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasMany.new(name: :shoes, collection_mapper: :a_collection_mapper)
        ]
      end
    end
  end

  describe "#type" do
    it "should update the type" do
      config = config().type :shoe
      expect(config.type).to be :shoe
    end
  end

  context 'multiple associations' do
    let(:config) {
      subject
        .has_many(:shoes)
        .has_one(:mother)
    }

    it 'should have them all present' do
      expect(config.associations).to include Yaks::Mapper::HasOne.new(name: :mother)
      expect(config.associations).to include Yaks::Mapper::HasMany.new(name: :shoes)
    end
  end
end
