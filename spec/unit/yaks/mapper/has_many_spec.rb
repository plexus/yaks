require 'spec_helper'

RSpec.describe Yaks::Mapper::HasMany do
  let(:closet_mapper) do
    Class.new(Yaks::Mapper) do
      has_many :shoes,
        rel: 'http://foo/shoes',
        mapper: Class.new(Yaks::Mapper) { type 'shoes' ; attributes :size, :color }
    end
  end

  let(:closet) {
    double(
      :shoes => [
        double(size: 9,    color: :blue),
        double(size: 11.5, color: :red),
      ]
    )
  }

  it 'should map the subresources' do
    expect(closet_mapper.new(closet, policy: Yaks::DefaultPolicy.new, env: {}).map_subresources).to eql(
      "http://foo/shoes" => Yaks::CollectionResource.new(
        type: 'shoes',
        members: [
          Yaks::Resource.new(type: 'shoes', attributes: {:size => 9, :color => :blue}),
          Yaks::Resource.new(type: 'shoes', attributes: {:size => 11.5, :color => :red})
        ]
      )
    )
  end

  describe '#collection_mapper' do
    let(:collection_mapper) { Yaks::Undefined }
    subject(:has_many)  { described_class.new(:name, :mapper, :rel, collection_mapper) }

    context 'when the collection mapper is undefined' do
      its(:collection_mapper) { should equal Yaks::CollectionMapper }
    end

    context 'when the collection mapper is specified' do
      let(:collection_mapper) { :foo }
      its(:collection_mapper) { should equal :foo }
    end
  end
end
