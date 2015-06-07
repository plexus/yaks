# Mainly tested through the acceptance tests, here covering a few specific edge cases
RSpec.describe Yaks::Format::JsonAPI do
  let(:format) { Yaks::Format::JsonAPI.new }

  context 'with no subresources' do
    let(:resource) { Yaks::Resource.new(type: 'wizard', attributes: {foo: :bar}) }

    it 'should not include an "included" key' do
      expect(format.call(resource)).to eql(
        data: {type: 'wizards', attributes: {foo: :bar}}
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
        data: [{type: 'wizards', attributes: {foo: :bar}}]
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
          type: 'wizards',
          relationships: {
            favourite_spell: {data: {type: "spells", id: "1"}}
          },
          links: {
            self: "/the/self/link",
            profile: "/the/profile/link"
          }
        },
        included: [{type: 'spells', id: "1"}]
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
          type: 'wizards',
          relationships: {favourite_spell: {data: {type: 'spells', id: "777"}}}
        },
        included: [{type: 'spells', id: "777", attributes: {name: 'Lucky Sevens'}}]
      )
    end
  end

  context 'with duplicate subresources' do
    let(:resource) {
      Yaks::CollectionResource.new(
        type: 'wizard',
        members: [
          Yaks::Resource.new(type: 'wizard', attributes: {id: 7}, subresources: [
            Yaks::Resource.new(type: 'spell', attributes: {id: 1}, rels: ['rel:favourite_spell']),
          ]),
          Yaks::Resource.new(type: 'wizard', attributes: {id: 3}, subresources: [
            Yaks::Resource.new(type: 'spell', attributes: {id: 1}, rels: ['rel:favourite_spell']),
          ]),
          Yaks::Resource.new(type: 'wizard', attributes: {id: 2}, subresources: [
            Yaks::Resource.new(type: 'spell', attributes: {id: 12}, rels: ['rel:favourite_spell']),
          ]),
          Yaks::Resource.new(type: 'wizard', attributes: {id: 9}, subresources: [
            Yaks::Resource.new(type: 'wand', attributes: {id: 1}, rels: ['rel:wand']),
          ]),
        ],
      )
    }

    it 'should include the each subresource only once' do
      expect(format.call(resource)).to eql(
        data: [
          {type: 'wizards', id: '7', relationships: {favourite_spell: {data: {type: 'spells', id: '1'}}}},
          {type: 'wizards', id: '3', relationships: {favourite_spell: {data: {type: 'spells', id: '1'}}}},
          {type: 'wizards', id: '2', relationships: {favourite_spell: {data: {type: 'spells', id: '12'}}}},
          {type: 'wizards', id: '9', relationships: {wand:            {data: {type: 'wands',  id: '1'}}}},
        ],
        included: [
          {type: 'spells', id: '1'},
          {type: 'spells', id: '12'},
          {type: 'wands',  id: '1'},
        ]
      )
    end
  end

  context 'with null subresources' do
    let(:resource) {
      Yaks::Resource.new(
        type: 'wizard',
        subresources: [subresource]
      )
    }

    context "non-collection subresouce" do
      let(:subresource) { Yaks::NullResource.new.add_rel("rel:wand") }

      it 'should include a nil linkage object' do
        expect(format.call(resource)).to eql(
          data: {
            type: 'wizards',
            relationships: {
              wand: {data: nil}
            }
          }
        )
      end
    end

    context "collection subresouce" do
      let(:subresource) { Yaks::NullResource.new(collection: true).add_rel("rel:wands") }

      it 'should include a nil linkage object' do
        expect(format.call(resource)).to eql(
          data: {
            type: 'wizards',
            relationships: {
              wands: {data: []}
            }
          }
        )
      end
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
        data: {type: 'wizards'}
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
