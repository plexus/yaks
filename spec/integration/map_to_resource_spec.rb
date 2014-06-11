require 'spec_helper'

RSpec.describe 'Mapping domain models to Resource objects' do
  include_context 'fixtures'

  subject { mapper.to_resource }
  let(:mapper) { FriendMapper.new(john, policy: Yaks::DefaultPolicy.new, env: {}) }

  it { should be_a Yaks::Resource }
  its(:type)         { should eql 'friend' }
  its(:attributes)   { should eql(id: 1, name: 'john') }
  its(:links)        { should eql [ Yaks::Resource::Link.new(:copyright, '/api/copyright/2024', {}) ] }

  its(:subresources) {
    should eq(
      "rel:src=friend&dest=pet_peeve" => Yaks::Resource.new(type:'pet_peeve', attributes: {id: 4, type: 'parsing with regexps'}),
      "rel:src=friend&dest=pets" => Yaks::CollectionResource.new(
        type: 'pet',
        members: [
          Yaks::Resource.new(type: 'pet', attributes: {:id => 2, :species => "dog", :name => "boingboing"}),
          Yaks::Resource.new(type: 'pet', attributes: {:id => 3, :species => "cat", :name => "wassup"})
        ]
      )
    )
  }
end
