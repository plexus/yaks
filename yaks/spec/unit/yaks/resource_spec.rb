require 'spec_helper'

RSpec.describe Yaks::Resource do
  subject(:resource) { described_class.new(init_opts) }
  let(:init_opts) { {} }

  context 'with a zero-arg constructor' do
    subject(:resource) { described_class.new }

    its(:type)           { should be_nil }
    its(:attributes)     { should eql({}) }
    its(:links)          { should eql [] }
    its(:subresources)   { should eql({}) }
    its(:self_link)      { should be_nil }
    its(:null_resource?) { should be false }
    its(:collection?)    { should be false }
  end

  context 'with a type' do
    let(:init_opts) { { type: 'post' } }
    its(:type) { should eql 'post' }
  end

  context 'with attributes' do
    let(:init_opts) { { attributes: {name: 'Arne', age: 31} } }

    it 'should delegate [] to attribute access' do
      expect(resource[:name]).to eql 'Arne'
    end
  end

  context 'with links' do
    let(:init_opts) {
      {
        links: [
          Yaks::Resource::Link.new(rel: :profile, uri: '/foo/bar/profile'),
          Yaks::Resource::Link.new(rel: :self, uri: '/foo/bar')
        ]
      }
    }
    its(:links) { should eql [
        Yaks::Resource::Link.new(rel: :profile, uri: '/foo/bar/profile'),
        Yaks::Resource::Link.new(rel: :self, uri: '/foo/bar')
      ]
    }

    its(:self_link) { should eql Yaks::Resource::Link.new(rel: :self, uri: '/foo/bar') }
  end

  context 'with subresources' do
    let(:init_opts) { { subresources: { 'comments' => [Yaks::Resource.new(type: 'comment')] } } }
    its(:subresources) { should eql 'comments' => [Yaks::Resource.new(type: 'comment')]  }

    it 'should return an enumerator for #each' do
      expect(resource.each.with_index.to_a).to eq  [ [resource, 0] ]
    end
  end


  it 'should act as a collection of one' do
    expect(resource.each.to_a).to eql [resource]
  end

  describe 'persistent updates' do
    let(:resource) {
      Yaks::Resource.new(
        attributes: {x: :y},
        links: [:one],
        subresources: {foo_rel: :subres}
      )
    }

    it 'should do updates without modifying the original' do
      expect(
        resource
          .update_attributes(foo: :bar)
          .add_link(:a_link)
          .add_subresource(:rel, :a_subresource)
          .update_attributes(foo: :baz)
      ).to eq Yaks::Resource.new(
        attributes: {x: :y, foo: :baz},
        links: [:one, :a_link],
        subresources: {foo_rel: :subres, rel: :a_subresource}
      )

      expect(resource).to eq Yaks::Resource.new(
        attributes: {x: :y},
        links: [:one],
        subresources: {foo_rel: :subres}
      )
    end
  end

  describe '#self_link' do
    let(:init_opts) {
      { links:
        [
          Yaks::Resource::Link.new(rel: :self, uri: 'foo'),
          Yaks::Resource::Link.new(rel: :self, uri: 'bar'),
          Yaks::Resource::Link.new(rel: :profile, uri: 'baz')
        ]
      }
    }
    it 'should return the last self link' do
      expect(resource.self_link).to eql Yaks::Resource::Link.new(rel: :self, uri: 'bar')
    end
  end

  describe '#add_control' do
    it 'should append to the controls' do
      expect(resource.add_control(:a_control))
        .to eq Yaks::Resource.new(controls: [:a_control])
    end
  end

  describe '#collection_rel' do
    it 'should raise unsupported operation error' do
      expect { resource.collection_rel }.to raise_error(
        Yaks::UnsupportedOperationError, "Only Yaks::CollectionResource has a collection_rel"
      )
    end
  end

  describe '#members' do
    it 'should raise unsupported operation error' do
      expect { resource.members }.to raise_error(
        Yaks::UnsupportedOperationError, "Only Yaks::CollectionResource has members"
      )
    end
  end

end
