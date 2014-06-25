require 'spec_helper'

RSpec.describe Yaks::Mapper::HasOne do
  include_context 'yaks context'

  AuthorMapper = Class.new(Yaks::Mapper) { attributes :name }

  subject(:has_one)  do
    described_class.new(
      name: :author,
      mapper: association_mapper,
      rel: 'http://rel'
    )
  end

  let(:association_mapper) { AuthorMapper }
  let(:name)               { 'William S. Burroughs' }
  let(:author)             { double(:name => name) }

  let(:policy) {
    double(
      Yaks::DefaultPolicy,
      derive_type_from_mapper_class: 'author',
      derive_mapper_from_association: AuthorMapper
    )
  }

  its(:singular_name) { should eq 'author' }

  it 'should map to a single Resource' do
    expect(has_one.map_resource(author, yaks_context)).to eq Yaks::Resource.new(type: 'author', attributes: {name: name})
  end

  context 'with no mapper specified' do
    subject(:subresource)    { has_one.add_to_resource(Yaks::Resource.new, parent_mapper, yaks_context) }
    let(:association_mapper) { Yaks::Undefined }
    let(:parent_mapper)      { double(Yaks::Mapper) }

    before do
      expect(parent_mapper).to receive(:load_association).with(:author).and_return(author)
    end

    it 'should derive one based on policy' do
      expect(subresource).to eql(
        Yaks::Resource.new(
          subresources: {
            'http://rel' => Yaks::Resource.new(type: 'author', attributes: {name: name})
          }
        )
      )
    end

  end
end
