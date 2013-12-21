require 'spec_helper'

describe Yaks::Mapper::HasOne do
  let(:name)     { 'William S. Burroughs' }
  let(:mapper)   { Class.new(Yaks::Mapper) { attributes :name } }
  let(:has_one)  { described_class.new(:author, mapper, []) }
  let(:author)   { Struct.new(:name).new(name) }

  it 'should map to a single Resource' do
    expect(has_one.map_resource(author)).to eq Yaks::Resource.new(nil, Yaks::Hash(name: name), nil, nil)
  end
end
