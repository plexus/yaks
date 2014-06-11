require 'spec_helper'

RSpec.describe Yaks::CollectionMapper do
  include_context 'fixtures'

  subject(:mapper) { described_class.new(collection, context) }
  let(:context) {
    { resource_mapper: resource_mapper,
      policy: policy,
      env: {}
    }
  }
  let(:collection) { [] }
  let(:resource_mapper) { Class.new(Yaks::Mapper) { type 'the_type' } }
  let(:policy) { Yaks::DefaultPolicy.new }

  its(:to_resource) {
    should eql Yaks::CollectionResource.new(
        type: 'the_type',
        links: [],
        attributes: {},
        members: []
    )
  }

  context 'with members' do
    let(:collection) { [boingboing, wassup]}
    let(:resource_mapper) { PetMapper }

    its(:to_resource) {
      should eql Yaks::CollectionResource.new(
        type: 'pet',
        links: [],
        attributes: {},
        members: [
          Yaks::Resource.new(type: 'pet', attributes: {:id => 2, :species => "dog", :name => "boingboing"}),
          Yaks::Resource.new(type: 'pet', attributes: {:id => 3, :species => "cat", :name => "wassup"})
        ]
      )
    }
  end

  context 'with collection attributes' do
    subject(:mapper) {
      Class.new(Yaks::CollectionMapper) do
        attributes :foo, :bar
      end.new(collection, context)
    }

    let(:collection) {
      Class.new(SimpleDelegator) do
        def foo ; 123 ; end
        def bar ; 'pi la~~~' ; end
      end.new([])
    }

    its(:to_resource) {
      should eql Yaks::CollectionResource.new(
        type: 'the_type',
        links: [],
        attributes: { foo: 123, bar: 'pi la~~~' },
        members: []
      )
    }
  end

  context 'with collection links' do
    subject(:mapper) {
      Class.new(Yaks::CollectionMapper) do
        link :self, 'http://api.example.com/orders'
      end.new(collection, context)
    }

    its(:to_resource) {
      should eql Yaks::CollectionResource.new(
        type: 'the_type',
        links: [ Yaks::Resource::Link.new(:self, 'http://api.example.com/orders', {}) ],
        attributes: { },
        members: []
      )
    }
  end

end
