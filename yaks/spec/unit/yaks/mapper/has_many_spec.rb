RSpec.describe Yaks::Mapper::HasMany do
  include_context 'yaks context'

  let(:closet_mapper) { closet_mapper_class.new(yaks_context) }

  let(:closet_mapper_class) do
    Class.new(Yaks::Mapper) do
      type 'closet'
      has_many :shoes,
        rel: 'http://foo/shoes',
        item_mapper: Class.new(Yaks::Mapper) { type 'shoe' ; attributes :size, :color }
    end
  end

  subject(:shoe_association) { closet_mapper.associations.first }

  describe "#singular_name" do
    its(:singular_name) { should eq 'shoe' }
  end

  let(:closet) {
    fake(
      :shoes => [
        fake(size: 9,    color: :blue),
        fake(size: 11.5, color: :red),
      ]
    )
  }

  describe "#map_resource" do
     it 'should map the subresources' do
       expect(closet_mapper.call(closet).subresources).to eql([
         Yaks::CollectionResource.new(
           type: 'shoe',
           members: [
             Yaks::Resource.new(type: 'shoe', attributes: {size: 9, color: :blue}),
             Yaks::Resource.new(type: 'shoe', attributes: {size: 11.5, color: :red})
           ],
           rels: ['http://foo/shoes']
         )
       ])
     end

     it 'should map nil to a NullResource collection' do
       expect(closet_mapper.call(fake(shoes: nil)).subresources).to eql([
         Yaks::NullResource.new(collection: true, rels: ['http://foo/shoes'])
       ])
     end

     context 'without an explicit mapper' do
       let(:dress_mapper) {
         Class.new(Yaks::Mapper) { type 'dress' ; attributes :color }
       }

       before do
         closet_mapper_class.class_eval do
           has_many :dresses
         end

         stub(closet_mapper.policy).derive_mapper_from_association(any_args) do
           dress_mapper
         end
       end

       it 'should derive it from policy' do
         expect(closet_mapper.policy).to equal policy
         closet_mapper.call(fake(shoes: [], dresses: [fake(color: 'blue')]))
       end
     end
  end

  describe '#collection_mapper' do
    let(:collection_mapper) { Yaks::Undefined }

    subject(:has_many)  { described_class.new(name: :name, item_mapper: :mapper, rel: :rel, collection_mapper: collection_mapper) }

    context 'when the collection mapper is undefined' do
      it 'should derive one from collection and policy' do
        expect(has_many.collection_mapper([], Yaks::DefaultPolicy.new)).to equal Yaks::CollectionMapper
      end

      it 'should return nil if no policy is given' do
        expect(has_many.collection_mapper([])).to be_nil
      end

      it 'should return nil if no collection is given' do
        expect(has_many.collection_mapper(nil, Yaks::DefaultPolicy.new)).to be_nil
      end

      it 'should return nil if no params are given' do
        expect(has_many.collection_mapper).to be_nil
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
