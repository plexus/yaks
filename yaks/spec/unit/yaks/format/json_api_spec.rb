# Mainly tested through the acceptance tests, here covering a few specific edge cases
RSpec.describe Yaks::Format::JsonAPI do
  let(:format) { Yaks::Format::JsonAPI.new }

  context 'with no subresources' do
    let(:resource) { Yaks::Resource.new(type: 'wizard', attributes: {foo: :bar}) }

    it 'should not include an "included" key' do
      expect(format.call(resource)).to eql(
        data: {type: :wizards, attributes: {foo: :bar}}
      )
    end
  end

  context 'collection with metadata' do
    let(:resource) {
      Yaks::CollectionResource.new(
        type: 'wizard',
        members: [Yaks::Resource.new(type: 'wizard', attributes: {foo: :bar})],
        attributes: {meta: {page: {limit: 20, offset: 0, count: 25}}}
      )
    }

    it 'should include the "meta" key' do
      expect(format.call(resource)).to eql(
        meta: {page: {limit: 20, offset: 0, count: 25}},
        data: [{type: :wizards, attributes: {foo: :bar}}]
      )
    end
  end

  context 'with links and subresources' do
    let(:resource) {
      Yaks::Resource.new(
        type: 'wizard',
        subresources: [
          Yaks::Resource.new(rels: ['rel:favourite_spell'], type: 'spell', attributes: {id: 1}),
        ],
        links: [
          Yaks::Resource::Link.new(rel: :self, uri: '/the/self/link'),
          Yaks::Resource::Link.new(rel: :profile, uri: '/the/profile/link'),
        ]
      )
    }

    it 'should include the links in the "links" key' do
      expect(format.call(resource)).to eql(
        data: {
          type: :wizards,
          links: {
            self: "/the/self/link",
            profile: "/the/profile/link",
            'favourite_spell' => {linkage: {type: "spells", id: "1"}},
          }
        },
        included: [{type: :spells, id: "1"}]
      )
    end
  end

  context 'with subresources' do
    let(:resource) {
      Yaks::Resource.new(
        type: 'wizard',
        subresources: [
          Yaks::Resource.new(rels: ['rel:favourite_spell'], type: 'spell', attributes: {id: 777, name: 'Lucky Sevens'})
        ]
      )
    }

    it 'should include subresource links and included' do
      expect(format.call(resource)).to eql(
        data: {
          type: :wizards,
          links: {'favourite_spell'  => {linkage: {type: 'spells', id: "777"}}}
        },
        included: [{type: :spells, id: "777", attributes: {name: 'Lucky Sevens'}}]
      )
    end
  end

  context 'with null subresources' do
    let(:resource) {
      Yaks::Resource.new(
        type: 'wizard',
        subresources: [Yaks::NullResource.new]
      )
    }

    it 'should not include subresource links' do
      expect(format.call(resource)).to eql(
        data: {type: :wizards}
      )
    end
  end

  context 'with no subresources or subresource links' do
    let(:resource) {
      Yaks::Resource.new(
        type: 'wizard',
        subresources: []
      )
    }

    it 'should not include subresource links' do
      expect(format.call(resource)).to eql(
        data: {type: :wizards}
      )
    end
  end

  context 'with links as collection' do
    let(:resource) {
      Yaks::CollectionResource.new(
        type: 'wizard',
        links: [
          Yaks::Resource::Link.new(rel: :prev, uri: '/prev/page/link'),
          Yaks::Resource::Link.new(rel: :next, uri: '/next/page/link'),
        ]
      )
    }

    it 'should include links' do
      expect(format.call(resource)).to eql(
        data: [],
        links: {
          prev: '/prev/page/link',
          next: '/next/page/link',
        }
      )
    end
  end
end
