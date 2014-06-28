require 'spec_helper'

RSpec.describe Yaks::Mapper::ClassMethods do
  subject(:mapper_class) do
    Class.new do
      extend Yaks::Mapper::ClassMethods
      attributes :foo, :bar
      link :some_rel, 'http://some_link'
      has_one :thing
      has_many :thingies
    end
  end

  describe 'attributes' do
    it 'should allow setting them' do
      expect( mapper_class.attributes ).to eq [
        Yaks::Mapper::Attribute.new(:foo),
        Yaks::Mapper::Attribute.new(:bar)
      ]
    end

    describe 'with inheritance' do
      let(:child_class) do
        Class.new(mapper_class) do
          attributes :baz
        end
      end

      let(:grandchild_class) do
        Class.new(child_class)
      end

      it 'should inherit attributes from the parent' do
        expect(child_class.attributes).to eq [
          Yaks::Mapper::Attribute.new(:foo),
          Yaks::Mapper::Attribute.new(:bar),
          Yaks::Mapper::Attribute.new(:baz)
        ]
      end

      it 'should create a valid config' do
        expect(grandchild_class.config).to be_a Yaks::Mapper::Config
      end

      it 'should not alter the parent' do
        expect(mapper_class.attributes).to eq [
          Yaks::Mapper::Attribute.new(:foo),
          Yaks::Mapper::Attribute.new(:bar),
        ]
      end
    end
  end

  it 'should register links' do
    expect(mapper_class.config.links).to eq [
      Yaks::Mapper::Link.new(:some_rel, 'http://some_link', {})
    ]
  end

  it 'should register associations' do
    expect(mapper_class.config.associations).to eq [
      Yaks::Mapper::HasOne.new(name: :thing),
      Yaks::Mapper::HasMany.new(name: :thingies)
    ]
  end

end
