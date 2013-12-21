require 'spec_helper'

describe Yaks::Mapper::Config do
  subject(:config) { described_class.new }

  describe 'attributes' do
    context 'an empty config' do
      it 'should return an empty attributes list' do
        expect(config.attributes).to eq Yaks::List()
      end
    end

    it 'should add attributes' do
      expect(config.attributes(:foo, :bar, :baz).attributes)
        .to eq Hamster.list(:foo, :bar, :baz)
    end

    it 'should be chainable' do
      expect(
        config
          .attributes(:foo, :bar)
          .attributes(:baz)
          .attributes
      ).to eq Hamster.list(:foo, :bar, :baz)
    end
  end

  describe 'links' do
    context 'an empty config' do
      it 'should have an empty link list' do
        expect(config.links).to eq Yaks::List()
      end
    end

    describe 'adding a link' do
      let(:config) { subject.link(:self, '/foo/bar/{id}') }

      it 'should have it in the link list' do
        expect(config.links).to eq Yaks::List(Yaks::Mapper::Link.new(:self, '/foo/bar/{id}'))
      end
    end
  end

  describe 'associations' do
    describe 'has_one' do
      let(:config) { subject.has_one :mother, mapper: Yaks::Mapper }

      it 'should have the association configured' do
        expect(config.associations).to eq Yaks::List(Yaks::Mapper::HasOne.new(:mother, :mother, Yaks::Mapper, Yaks::List()))
      end
    end

    describe 'has_many' do
      let(:config) { subject.has_many :shoes, mapper: Yaks::Mapper }

      it 'should have the association configured' do
        expect(config.associations).to eq Yaks::List(Yaks::Mapper::HasMany.new(:shoes, :shoes, Yaks::Mapper, Yaks::List()))
      end
    end

    context 'with an :as alternate key' do
      let(:config) { subject.has_many :shoes, as: :footwear, mapper: Yaks::Mapper }

      it 'should have the given value as its "key"' do
        expect(config.associations.first.key).to eq :footwear
      end
    end
  end
end
