require 'spec_helper'

describe 'Mapping domain models to Resource objects' do
  include_context 'fixtures'

  subject { mapper.to_resource }
  let(:mapper) { FriendMapper.new(john) }

  it { should be_a Yaks::Resource }
  its(:attributes)   { should eq Yaks::Hash(id: 1, name: 'john') }
  its(:links)        { should eq Yaks::List(Yaks::Resource::Link.new(:copyright, '/api/copyright/2024')) }
  its(:subresources) {
    should eq Yaks::Hash(
      pet_peeve: Yaks::Resource.new(
        Yaks::Hash(id: 4, type: 'parsing with regexps'),
        nil,
        nil
      )
    )
  }
end
