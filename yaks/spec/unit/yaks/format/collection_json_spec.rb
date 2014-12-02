require 'spec_helper'

RSpec.describe Yaks::Format::CollectionJson do
  context 'with the plant collection resource' do
    include_context 'plant collection resource'

    subject { Yaks::Primitivize.create.call(described_class.new.call(resource)) }

    it { should deep_eql(load_json_fixture('plant_collection.collection')) }
  end

  context 'link' do
    context 'without title' do
      let(:resource) {
        Yaks::Resource.new(
          attributes: {foo: 'fooval', bar: 'barval'},
          links: [Yaks::Resource::Link.new(rel: 'the_rel', uri: 'the_uri')]
        )
      }

      subject {
        Yaks::Primitivize.create.call(described_class.new.call(resource))
      }

      it 'should not render a name' do
        should deep_eql(
          "collection" => {
            "version" => "1.0",
            "items" => [
              {
                "data" => [
                  { "name"=>"foo", "value"=>"fooval" },
                  { "name"=>"bar", "value"=>"barval" }
                ],
                "links" => [{"rel"=>"the_rel", "href"=>"the_uri"}]
              }
            ]
          }
        )
      end
    end

    context 'with a title' do
      let(:resource) {
        Yaks::Resource.new(
          attributes: {foo: 'fooval', bar: 'barval'},
          links: [Yaks::Resource::Link.new(options: {title: 'the_name'}, rel: 'the_rel', uri: 'the_uri')]
        )
      }

      subject {
        Yaks::Primitivize.create.call(described_class.new.call(resource))
      }

      it 'should render a name' do
        should deep_eql(
          "collection" => {
            "version" => "1.0",
            "items" => [
              {
                "data" => [
                  { "name"=>"foo", "value"=>"fooval" },
                  { "name"=>"bar", "value"=>"barval" }
                ],
                "links" => [{"name"=>"the_name", "rel"=>"the_rel", "href"=>"the_uri"}]
              }
            ]
          }
        )
      end
    end
  end
end
