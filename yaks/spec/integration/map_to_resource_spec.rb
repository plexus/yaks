RSpec.describe 'Mapping domain models to Resource objects' do
  include_context 'fixtures'
  include_context 'yaks context'

  subject { mapper.call(john) }
  let(:mapper) { FriendMapper.new(yaks_context) }

  it { should be_a Yaks::Resource }
  its(:type)         { should eql 'friend' }
  its(:attributes)   { should eql(id: 1, name: 'john') }
  its(:links)        { should eql [ Yaks::Resource::Link.new(rel: :copyright, uri: '/api/copyright/2024') ] }

  specify {
    subject.subresources == [
      Yaks::Resource.new(
        type:'pet_peeve',
        rels: ['rel:pet_peeve'],
        attributes: {id: 4, type: 'parsing with regexps'}
      ),
      Yaks::CollectionResource.new(
        type: 'pet',
        rels: ['rel:pets'],
        members: [
          Yaks::Resource.new(
            type: 'pet',
            attributes: {id: 2, species: 'dog', name: 'boingboing'}
          ),
          Yaks::Resource.new(
            type: 'pet',
            attributes: {id: 3, species: 'cat', name: 'wassup'}
          )
        ]
      )
    ]
  }

  its(:subresources) {
    should eq(
      [
        Yaks::Resource.new(
          type:'pet_peeve',
          rels: ['rel:pet_peeve'],
          attributes: {id: 4, type: 'parsing with regexps'}
        ),
        Yaks::CollectionResource.new(
          type: 'pet',
          rels: ['rel:pets'],
          members: [
            Yaks::Resource.new(
              type: 'pet',
              attributes: {id: 2, species: 'dog', name: 'boingboing'}
            ),
            Yaks::Resource.new(
              type: 'pet',
              attributes: {id: 3, species: 'cat', name: 'wassup'}
            )
          ]
        )
      ]
    )
  }
end
