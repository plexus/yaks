RSpec.describe Yaks::Mapper::HasOne do
  include_context 'yaks context'

  AuthorMapper = Class.new(Yaks::Mapper) { attributes :name }

  subject(:has_one) do
    described_class.new(
      name: :author,
      item_mapper: association_mapper,
      rel: 'http://rel'
    )
  end

  let(:association_mapper) { AuthorMapper }
  let(:name)               { 'William S. Burroughs' }
  let(:author)             { fake(name: name) }

  fake(:policy,
    derive_type_from_mapper_class: 'author',
    derive_mapper_from_association: AuthorMapper
  ){ Yaks::DefaultPolicy }

  describe "#singular_name" do
    its(:singular_name) { should eq 'author' }
  end

  describe "#map_resource" do
    it 'should map to a single Resource' do
      expect(has_one.map_resource(author, yaks_context))
        .to eq Yaks::Resource.new(type: 'author', attributes: {name: name})
    end

    context 'with no mapper specified' do
      subject(:subresource) {
        has_one.add_to_resource(Yaks::Resource.new, parent_mapper, yaks_context)
      }
      let(:association_mapper) { Yaks::Undefined }
      fake(:parent_mapper) { Yaks::Mapper }

      before do
        stub(parent_mapper).load_association(:author) { author }
      end

      it 'should derive one based on policy' do
        expect(subresource).to eql(
          Yaks::Resource.new(subresources: [
            Yaks::Resource.new(
              type: 'author',
              attributes: {name: name},
              rels: ['http://rel']
            )
          ])
        )
      end
    end
  end
end
