require 'spec_helper'

RSpec.describe Yaks::CollectionResource do
  subject(:collection) { described_class.new(init_opts) }
  let(:init_opts) { {} }

  its(:collection?)    { should be true }
  its(:null_resource?) { should be false }

  context 'with nothing passed in the contstructor' do
    its(:type)         { should be_nil  }
    its(:links)        { should eql []  }
    its(:attributes)   { should eql({}) }
    its(:members)      { should eql []  }
    its(:subresources) { should eql({}) }
    its(:collection_rel)  { should eql('members') }
  end

  context 'with a full constructor' do
    let(:init_opts) {
      {
        type: 'order',
        links: [
          Yaks::Resource::Link.new(rel: 'http://rels/summary', uri: 'http://order/10/summary'),
          Yaks::Resource::Link.new(rel: :profile, uri: 'http://rels/collection')
        ],
        attributes: { total: 10.00 },
        members: [
          Yaks::Resource.new(
            type: 'order',
            links: [Yaks::Resource::Link.new(rel: :self, uri: 'http://order/10')],
            attributes: { customer: 'John Doe', price: 10.00 }
          )
        ],
        collection_rel: 'http://api.example.org/rels/orders'
      }
    }

    its(:type)       { should eql 'order' }
    its(:links)      { should eql [
        Yaks::Resource::Link.new(rel: 'http://rels/summary', uri: 'http://order/10/summary'),
        Yaks::Resource::Link.new(rel: :profile, uri: 'http://rels/collection')
      ]
    }
    its(:attributes) { should eql( total: 10.00 ) }
    its(:members)    { should eql [
        Yaks::Resource.new(
          type: 'order',
          links: [Yaks::Resource::Link.new(rel: :self, uri: 'http://order/10')],
          attributes: { customer: 'John Doe', price: 10.00 }
        )
      ]
    }
    its(:collection_rel) { should eq 'http://api.example.org/rels/orders'}

    its(:subresources) { should eql({}) }

  end
end
