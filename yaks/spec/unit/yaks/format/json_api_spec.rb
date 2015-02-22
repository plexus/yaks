# Mainly tested through the acceptance tests, here covering a few specific edge cases
RSpec.describe Yaks::Format::JsonAPI do
  let(:format) { Yaks::Format::JsonAPI.new }

  context 'with no subresources' do
    let(:resource) { Yaks::Resource.new(type: 'wizard', attributes: {foo: :bar}) }

    it 'should not include a "linked" key' do
      expect(format.call(resource)).to eql(
        {data: [{type: :wizards, foo: :bar}]}
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
        {data: [
            {
              type: :wizards,
              href: '/the/href'
            }
          ]
        }
      )
    end
  end

end
