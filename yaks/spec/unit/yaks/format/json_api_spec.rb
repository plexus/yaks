# Mainly tested through the acceptance tests, here covering a few specific edge cases
RSpec.describe Yaks::Format::JsonAPI do
  let(:format) { Yaks::Format::JsonAPI.new }

  context 'with no subresources' do
    let(:resource) { Yaks::Resource.new(type: 'wizard', attributes: {foo: :bar}) }

    it 'should not include an "included" key' do
      expect(format.call(resource)).to eql(
        data: {type: :wizards, foo: :bar}
      )
    end
  end

  context 'collection with metadata' do
    let(:resource) { Yaks::CollectionResource.new(
        type: 'wizard',
        members: [Yaks::Resource.new(type: 'wizard', attributes: {foo: :bar})],
        attributes: {meta: {page: {limit: 20, offset: 0, count: 25}}}
    )
    }

    it 'should include the "meta" key' do
      expect(format.call(resource)).to eql(
        meta: {page: {limit: 20, offset: 0, count: 25}},
        data: [{type: :wizards, foo: :bar}]
      )
    end
  end

  context 'with both a "href" attribute and a self link' do
    let(:resource) {
      Yaks::Resource.new(
        type: 'wizard',
        attributes: {
          href: '/the/href'
        },
        links: [
          Yaks::Resource::Link.new(rel: :self, uri: '/the/self/link')
        ]
      )
    }

    # TODO should it really behave this way? better to give preference to self link.
    it 'should give preference to the href attribute' do
      expect(format.call(resource)).to eql(
        data: {type: :wizards, href: '/the/href'}
      )
    end
  end

  context 'with a self link' do
    let(:resource) {
      Yaks::Resource.new(
          type: 'wizard',
          links: [
              Yaks::Resource::Link.new(rel: :self, uri: '/the/self/link')
          ]
      )
    }
    it 'should use the self link in output' do
      expect(format.call(resource)).to eql(
        data: {type: :wizards, href: '/the/self/link'}
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
    it 'should include links and included' do
      expect(format.call(resource)).to eql(
        data: {
          type: :wizards,
          links: {'favourite_spell'  => {linkage: {type: 'spells', id: 777}}}
        },
        included: [{type: :spells, id: 777, name: 'Lucky Sevens'}]
      )
    end

  end

  context 'with null subresources' do
    let(:resource) {
      Yaks::Resource.new(
          type: 'wizard',
          subresources: [
              Yaks::NullResource.new
          ]
      )
    }
    it 'should not include links' do
      expect(format.call(resource)).to eql(
        data: {type: :wizards}
      )
    end
  end

  context 'with no subresources or links' do
    let(:resource) {
      Yaks::Resource.new(
          type: 'wizard',
          subresources: []
      )
    }
    it 'should not include links' do
      expect(format.call(resource)).to eql(
        data: {type: :wizards}
      )
    end
  end

end
