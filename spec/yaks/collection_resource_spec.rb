require 'spec_helper'

describe Yaks::CollectionResource do
  it 'should normalize its arguments' do
    expect(described_class.new(nil, nil)).to eq(
      described_class.new(Yaks::List(), Yaks::List())
    )
  end
end
