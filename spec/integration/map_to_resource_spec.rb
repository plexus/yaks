require 'spec_helper'

describe 'Mapping domain models to Resource objects' do
  include_context 'fixtures'
  subject { mapper.map_to_resource }
  let(:mapper) { FriendMapper.new(john) }

  it { should be_a Yaks::Resource }
  its(:attributes) { should eq Yaks::Hash(id: 1, name: 'john') }
end
