require 'spec_helper'

describe Yaks::Serializer do
  include_context 'fixtures'

  let(:collection) { FriendSerializer.new.serialize_collection [john] }

  it do
    expect(Yaks::FoldJsonApi.new(collection).fold).to eq({})
  end

end
