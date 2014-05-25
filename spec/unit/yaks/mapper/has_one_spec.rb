require 'spec_helper'

describe Yaks::Mapper::HasOne do
  AuthorMapper = Class.new(Yaks::Mapper) { attributes :name }

  let(:name)     { 'William S. Burroughs' }
  let(:mapper)   { AuthorMapper }
  let(:has_one)  { described_class.new(:author, mapper, 'http://rel', Yaks::Undefined) }
  let(:author)   { double(:name => name) }
  let(:policy)   {
    double(
      Yaks::DefaultPolicy,
      derive_type_from_mapper_class: 'author',
      derive_mapper_from_association: AuthorMapper
    )
  }

  it 'should map to a single Resource' do
    expect(has_one.map_resource(author, policy)).to eq Yaks::Resource.new(type: 'author', attributes: {name: name})
  end

  context 'with no mapper specified' do
    let(:mapper)   { Yaks::Undefined }

    it 'should derive one based on policy' do
      expect(has_one.map_to_resource_pair(nil, {author: author}, policy)).to eql [
        'http://rel',
        Yaks::Resource.new(type: 'author', attributes: {name: name})
      ]
    end

  end
end
