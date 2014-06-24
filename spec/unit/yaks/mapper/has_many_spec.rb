require 'spec_helper'

RSpec.describe Yaks::Mapper::HasMany do
  include_context 'yaks context'

  let(:closet_mapper) { closet_mapper_class.new(yaks_context) }

  let(:closet_mapper_class) do
    Class.new(Yaks::Mapper) do
      type 'closet'
      has_many :shoes,
        rel: 'http://foo/shoes',
        mapper: Class.new(Yaks::Mapper) { type 'shoe' ; attributes :size, :color }
    end
  end

  subject(:shoe_association) { closet_mapper.associations.first }

  its(:singular_name) { should eq 'shoe' }

  let(:closet) {
    double(
      :shoes => [
        double(size: 9,    color: :blue),
        double(size: 11.5, color: :red),
      ]
    )
  }

  it 'should map the subresources' do
    expect(closet_mapper.call(closet).subresources).to eql(
      "http://foo/shoes" => Yaks::CollectionResource.new(
        type: 'shoe',
        members: [
          Yaks::Resource.new(type: 'shoe', attributes: {:size => 9, :color => :blue}),
          Yaks::Resource.new(type: 'shoe', attributes: {:size => 11.5, :color => :red})
        ],
        members_rel: 'rel:src=collection&dest=shoes'
      )
    )
  end

  describe '#collection_mapper' do
    let(:collection_mapper) { Yaks::Undefined }
    subject(:has_many)  { described_class.new(name: :name, mapper: :mapper, rel: :rel, collection_mapper: collection_mapper) }

    context 'when the collection mapper is undefined' do
      it 'should derive one from collection and policy' do
        expect(has_many.collection_mapper([], Yaks::DefaultPolicy.new)).to equal Yaks::CollectionMapper
      end
    end

    context 'when the collection mapper is specified' do
      let(:collection_mapper) { :foo }

      it 'should use the given collection mapper' do
        expect(has_many.collection_mapper([], Yaks::DefaultPolicy.new)).to equal :foo
      end
    end
  end
end
