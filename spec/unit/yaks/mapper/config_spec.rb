require 'spec_helper'

describe Yaks::Mapper::Config do
  Undefined = Yaks::Undefined

  subject(:config) { described_class.new(nil, [], [], []) }

  describe '#initialize' do
    subject(:config) { described_class.new('foo', [:a], [:b], [:c]) }

    its(:type)         { should eql 'foo' }
    its(:attributes)   { should eql [:a] }
    its(:links)        { should eql [:b] }
    its(:associations) { should eql [:c] }
  end

  describe '#updated' do
    context 'with no updates' do
      let(:config) {
        super()
          .type('foo')
          .attributes(:a, :b, :c)
          .link(:foo, 'http://bar')
          .has_many(:bars)
      }

      it 'should update attributes' do
        expect(config.updated(attributes: [:foo])).to eql described_class.new(
          'foo',
          [:foo],
          [Yaks::Mapper::Link.new(:foo, 'http://bar', {})],
          [Yaks::Mapper::HasMany.new(:bars, Undefined, Undefined, Undefined)]
        )
      end

      it 'should update links' do
        expect(config.updated(links: [:foo])).to eql described_class.new(
          'foo',
          [:a, :b, :c],
          [:foo],
          [Yaks::Mapper::HasMany.new(:bars, Undefined, Undefined, Undefined)]
        )
      end

      it 'should update associations' do
        expect(config.updated(associations: [:foo])).to eql described_class.new(
          'foo',
          [:a, :b, :c],
          [Yaks::Mapper::Link.new(:foo, 'http://bar', {})],
          [:foo]
        )
      end
    end
  end

  describe '#attributes' do
    context 'an empty config' do
      it 'should return an empty attributes list' do
        expect(config.attributes).to eq []
      end
    end

    it 'should add attributes' do
      expect(config.attributes(:foo, :bar, :baz).attributes)
        .to eq [:foo, :bar, :baz]
    end

    it 'should be chainable' do
      expect(
        config
          .attributes(:foo, :bar)
          .attributes(:baz)
          .attributes
      ).to eq [:foo, :bar, :baz]
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

  end

  describe '#has_one' do
    context 'with a mapper specified' do
      let(:config) { subject.has_one :mother, mapper: Yaks::Mapper }

      it 'should have the association configured' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasOne.new(:mother, Yaks::Mapper, Undefined, Undefined)
        ]
      end
    end

    context 'with no options' do
      let(:config) { subject.has_one :mother }

      it 'should have undefined mapper, rel, collection_mapper' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasOne.new(:mother, Undefined, Undefined, Undefined)
        ]
      end
    end

    context 'with a rel specified' do
      let(:config) { subject.has_one :mother, rel: '/api/rels/mother' }

      it 'should have the rel' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasOne.new(:mother, Undefined, '/api/rels/mother', Undefined)
        ]
      end

    end
  end

  describe '#has_many' do
    context 'with a mapper specified' do
      let(:config) { subject.has_many :shoes, mapper: Yaks::Mapper }

      it 'should have the association configured' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasMany.new(:shoes, Yaks::Mapper, Undefined, Undefined)
        ]
      end
    end

    context 'with no options' do
      let(:config) { subject.has_many :shoes }

      it 'should have undefined mapper, rel, collection_mapper' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasMany.new(:shoes, Undefined, Undefined, Undefined)
        ]
      end
    end

    context 'with a collection mapper set' do
      let(:config) { subject.has_many :shoes, collection_mapper: :a_collection_mapper }

      it 'should have the association configured' do
        expect(config.associations).to eq [
          Yaks::Mapper::HasMany.new(:shoes, Undefined, Undefined, :a_collection_mapper)
        ]
      end
    end
  end

  context 'multiple associations' do
    let(:config) {
      subject
        .has_many(:shoes)
        .has_one(:mother)
    }

    it 'should have them all present' do
      expect(config.associations).to include Yaks::Mapper::HasOne.new(:mother, Undefined, Undefined, Undefined)
      expect(config.associations).to include Yaks::Mapper::HasMany.new(:shoes, Undefined, Undefined, Undefined)
    end
  end
end
