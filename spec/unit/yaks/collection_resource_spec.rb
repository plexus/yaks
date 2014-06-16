require 'spec_helper'

RSpec.describe Yaks::CollectionResource do
  subject(:collection) { described_class.new(init_opts) }
  let(:init_opts) { {} }

  its(:collection?) { should equal true }

  context 'with nothing passed in the contstructor' do
    its(:type)         { should be_nil  }
    its(:links)        { should eql []  }
    its(:attributes)   { should eql({}) }
    its(:members)      { should eql []  }
    its(:subresources) { should eql({}) }
  end

  context 'with a full constructor' do
    let(:init_opts) {
      {
        type: 'order',
        links: [
          Yaks::Resource::Link.new('http://rels/summary', 'http://order/10/summary', {}),
          Yaks::Resource::Link.new(:profile, 'http://rels/collection', {})
        ],
        attributes: { total: 10.00 },
        members: [
          Yaks::Resource.new(
            type: 'order',
            links: [Yaks::Resource::Link.new(:self, 'http://order/10', {})],
            attributes: { customer: 'John Doe', price: 10.00 }
          )
        ]
      }
    }

    its(:type)       { should eql 'order' }
    its(:links)      { should eql [
        Yaks::Resource::Link.new('http://rels/summary', 'http://order/10/summary', {}),
        Yaks::Resource::Link.new(:profile, 'http://rels/collection', {})
      ]
    }
    its(:attributes) { should eql( total: 10.00 ) }
    its(:members)    { should eql [
        Yaks::Resource.new(
          type: 'order',
          links: [Yaks::Resource::Link.new(:self, 'http://order/10', {})],
          attributes: { customer: 'John Doe', price: 10.00 }
        )
      ]
    }

    its(:subresources) { should eql(
        'members' => Yaks::CollectionResource.new(
          type: 'order',
          attributes: { total: 10.00 },
          links: [
            Yaks::Resource::Link.new('http://rels/summary', 'http://order/10/summary', {}),
            Yaks::Resource::Link.new(:profile, 'http://rels/collection', {})
          ],
          members: [
            Yaks::Resource.new(
              type: 'order',
              links: [Yaks::Resource::Link.new(:self, 'http://order/10', {})],
              attributes: { customer: 'John Doe', price: 10.00 }
            )
          ],
        )
      )
    }

  end
end
