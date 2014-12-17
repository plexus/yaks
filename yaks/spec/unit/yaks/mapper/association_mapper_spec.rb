RSpec.describe Yaks::Mapper::AssociationMapper do
  include_context 'yaks context'

  subject(:association_mapper) { described_class.new(parent_mapper, association, yaks_context) }

  let(:parent_mapper_class) { Yaks::Mapper }
  let(:parent_mapper)       { parent_mapper_class.new(yaks_context) }

  fake(:association) { Yaks::Mapper::Association }

  its(:policy) { should be policy }

  let(:mapper_stack) { [:bottom_mapper] }

  describe '#call' do
    context 'when the association should be rendered as link' do
      before do
        stub(association).render_as_link?(parent_mapper) { true }
        stub(association).map_rel(policy) { 'rels:the_rel' }
        stub(association).href { 'http://this/is_where_the_associated_thing_can_be_found' }
      end

      it 'should render a link' do
        expect(association_mapper.call(Yaks::Resource.new)).to eql Yaks::Resource.new(
          links: [
            Yaks::Resource::Link.new(
              rel: 'rels:the_rel',
              uri: 'http://this/is_where_the_associated_thing_can_be_found'
            )
          ]
        )
      end
    end

    context 'when the association should be rendered as a subresource' do
      before do
        stub(association).render_as_link?(parent_mapper) { false }
        stub(association).map_rel(policy) { 'rels:the_rel' }
        stub(association).name { :the_name }
        stub(association).map_resource(:the_object, association_mapper.context) { Yaks::Resource.new }

        stub(parent_mapper).load_association(:the_name) { :the_object }
      end

      it 'should render a subresource' do
        expect(association_mapper.call(Yaks::Resource.new)).to eql Yaks::Resource.new(
          subresources: [ Yaks::Resource.new(rels: ['rels:the_rel']) ]
        )
      end

      it 'should add the mapper to the mapper_stack' do
        expect(association_mapper.context[:mapper_stack]).to eql [:bottom_mapper, parent_mapper]
      end
    end
  end
end
