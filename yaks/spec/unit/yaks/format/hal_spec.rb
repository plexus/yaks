RSpec.describe Yaks::Format::Hal do
  context 'with the plant collection resource' do
    include_context 'plant collection resource'

    subject { Yaks::Primitivize.create.call(described_class.new.call(resource)) }

    it { should deep_eql(load_json_fixture('plant_collection.hal')) }
  end

  context 'with multiple links on the same rel' do
    let(:format) {
      described_class.new(:plural_links => 'my_plural_rel')
    }

    let(:resource) {
      Yaks::Resource.new(
        attributes: {foo: 'fooval', bar: 'barval'},
        links: [
          Yaks::Resource::Link.new(rel: 'my_plural_rel', uri: 'the_uri1'),
          Yaks::Resource::Link.new(rel: 'my_plural_rel', uri: 'the_uri2')
        ]
      )
    }

    subject {
      Yaks::Primitivize.create.call(format.call(resource))
    }

    it 'should render both links' do
      should deep_eql(
        'foo' => 'fooval',
        'bar' => 'barval',
        '_links' => {
          "my_plural_rel" => [
            {"href"=>"the_uri1"},
            {"href"=>"the_uri2"}
          ]
        }
      )
    end
  end
end
