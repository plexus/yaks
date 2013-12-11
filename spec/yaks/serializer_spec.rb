require 'spec_helper'

describe Yaks::Serializer do
  include_context 'fixtures'

  let(:collection) { FriendSerializer.new.serializable_collection [john] }

  it do
    expect(Yaks::FoldJsonApi.new(collection).fold).to eq({})
  end

end
