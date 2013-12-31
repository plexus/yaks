require 'spec_helper'

describe 'Mapping domain models to Resource objects' do
  include_context 'fixtures'
  include_context 'shorthands'

  subject { mapper.to_resource }
  let(:mapper) { FriendMapper.new(john) }


  it { should be_a Yaks::Resource }
  its(:attributes)   { should eq Yaks::Hash(id: 1, name: 'john') }
  its(:links)        { should eq Yaks::List(
      resource_link[:profile, 'friend'],
      resource_link[:copyright, '/api/copyright/2024']
  )}

  its(:subresources) {
    should eq Yaks::Hash(
      "rel:src=friend&dest=pet_peeve" => resource[{id: 4, type: 'parsing with regexps'}, [resource_link[:profile, 'pet_peeve']]],
      "rel:src=friend&dest=pets" => Yaks::CollectionResource.new(
        [resource_link[:profile, 'pet']],
        [
          resource[{:id => 2, :species => "dog", :name => "boingboing"}, [resource_link[:profile, 'pet']]],
          resource[{:id => 3, :species => "cat", :name => "wassup"}, [resource_link[:profile, 'pet']]]
        ]
      )
    )
  }
end
