RSpec.shared_context 'collection resource' do
  let(:resource) do
    Yaks::CollectionResource.new(
      links: links,
      members: members,
      collection_rel: 'http://api.example.com/rels/plants'
    )
  end
  let(:links)    { [] }
  let(:members)  { [] }
end

RSpec.shared_context 'yaks context' do
  let(:policy)            { Yaks::DefaultPolicy.new }
  let(:rack_env)          { {} }
  let(:mapper_stack)      { [] }
  let(:yaks_context)      { { policy: policy, env: rack_env, mapper_stack: mapper_stack } }
end

RSpec.shared_context 'plant collection resource' do
  include_context 'collection resource'

  let(:links)   { [ plants_self_link, plants_profile_link ] }
  let(:members) { [ plain_grass, oak, passiflora ] }

  [
    [ :plant       , :profile , 'http://api.example.com/doc/plant'            ],
    [ :plants      , :profile , 'http://api.example.com/doc/plant_collection' ],
    [ :plants      , :self    , 'http://api.example.com/plants'               ],
    [ :plain_grass , :self    , 'http://api.example.com/plants/7/plain_grass' ],
    [ :oak         , :self    , 'http://api.example.com/plants/15/oak'        ],
    [ :passiflora  , :self    , 'http://api.example.com/plants/33/passiflora' ],
  ].each do |name, type, uri|
    let(:"#{name}_#{type}_link") { Yaks::Resource::Link.new(type, uri, {}) }
  end

  let(:plain_grass) do
    Yaks::Resource.new(
      attributes: {name: "Plain grass", type: "grass"},
      links: [plain_grass_self_link, plant_profile_link]
    )
  end

  let(:oak) do
    Yaks::Resource.new(
      attributes: {name: "Oak", type: "tree"},
      links: [oak_self_link, plant_profile_link],
    )
  end

  let(:passiflora) do
    Yaks::Resource.new(
      attributes: {name: "Passiflora", type: "flower"},
      links: [passiflora_self_link, plant_profile_link],
    )
  end
end
