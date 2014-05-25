require 'spec_helper'

describe 'Mapping domain models to Resource objects' do
  include_context 'fixtures'
  include_context 'shorthands'

  subject { mapper.to_resource }
  let(:mapper) { FriendMapper.new(john, Yaks::DefaultPolicy.new) }


  it { should be_a Yaks::Resource }
  its(:attributes)   { should eq(id: 1, name: 'john') }
  its(:links)        { should eq [ resource_link[:copyright, '/api/copyright/2024'] ] }

  its(:subresources) {
    should eq(
      "rel:src=friend&dest=pet_peeve" => Yaks::Resource.new({id: 4, type: 'parsing with regexps'}, [], {}),
      "rel:src=friend&dest=pets" => Yaks::CollectionResource.new(
        [],
        [
          Yaks::Resource.new({:id => 2, :species => "dog", :name => "boingboing"}, [], {}),
          Yaks::Resource.new({:id => 3, :species => "cat", :name => "wassup"}, [], {})
        ]
      )
    )
  }
end
