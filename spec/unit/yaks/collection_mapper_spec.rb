require 'spec_helper'

RSpec.describe Yaks::CollectionMapper do
  include_context 'fixtures'

  subject(:mapper) { described_class.new(context) }
  let(:context) {
    { member_mapper: member_mapper,
      policy: policy,
      env: {}
    }
  }
  let(:collection) { [] }
  let(:member_mapper) { Class.new(Yaks::Mapper) { type 'the_type' } }
  let(:policy) { Yaks::DefaultPolicy.new }

  it 'should map the collection' do
    expect(mapper.call(collection)).to eql Yaks::CollectionResource.new(
      type: 'the_type',
      links: [],
      attributes: {},
      members: [],
      members_rel: 'rel:src=collection&dest=the_types'
    )
  end

  context 'with members' do
    let(:collection) { [boingboing, wassup]}
    let(:member_mapper) { PetMapper }

    it 'should map the members' do
      mapper.call(collection)

      expect(mapper.call(collection)).to eql Yaks::CollectionResource.new(
        type: 'pet',
        links: [],
        attributes: {},
        members: [
          Yaks::Resource.new(type: 'pet', attributes: {:id => 2, :species => "dog", :name => "boingboing"}),
          Yaks::Resource.new(type: 'pet', attributes: {:id => 3, :species => "cat", :name => "wassup"})
        ],
        members_rel: 'rel:src=collection&dest=pets'
      )
    end
  end

  context 'with collection attributes' do
    subject(:mapper) {
      Class.new(Yaks::CollectionMapper) do
        attributes :foo, :bar
      end.new(context)
    }

    let(:collection) {
      Class.new(SimpleDelegator) do
        def foo ; 123 ; end
        def bar ; 'pi la~~~' ; end
      end.new([])
    }

    it 'should map the attributes' do
      expect(mapper.call(collection)).to eql Yaks::CollectionResource.new(
        type: 'the_type',
        links: [],
        attributes: { foo: 123, bar: 'pi la~~~' },
        members: [],
        members_rel: 'rel:src=collection&dest=the_types'
      )
    end
  end

  context 'with collection links' do
    subject(:mapper) {
      Class.new(Yaks::CollectionMapper) do
        link :self, 'http://api.example.com/orders'
      end.new(context)
    }

    it 'should map the links' do
      expect(mapper.call(collection)).to eql Yaks::CollectionResource.new(
        type: 'the_type',
        links: [ Yaks::Resource::Link.new(:self, 'http://api.example.com/orders', {}) ],
        attributes: { },
        members: [],
        members_rel: 'rel:src=collection&dest=the_types'
      )
    end
  end

end
