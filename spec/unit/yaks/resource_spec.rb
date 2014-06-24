require 'spec_helper'

RSpec.describe Yaks::Resource do
  subject(:resource) { described_class.new(init_opts) }
  let(:init_opts) { {} }

  its(:type)           { should be_nil }
  its(:attributes)     { should eql({}) }
  its(:links)          { should eql [] }
  its(:subresources)   { should eql({}) }
  its(:self_link)      { should be_nil }
  its(:null_resource?) { should be false }
  its(:collection?)    { should be false }

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
          Yaks::Resource::Link.new(:profile, '/foo/bar/profile', {}),
          Yaks::Resource::Link.new(:self, '/foo/bar', {})
        ]
      }
    }
    its(:links) { should eql [
        Yaks::Resource::Link.new(:profile, '/foo/bar/profile', {}),
        Yaks::Resource::Link.new(:self, '/foo/bar', {})
      ]
    }

    its(:self_link) { should eql Yaks::Resource::Link.new(:self, '/foo/bar', {}) }
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
end
