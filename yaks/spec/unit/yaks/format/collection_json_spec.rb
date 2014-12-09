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

  context 'queries' do
    let(:resource) {
      Yaks::Resource.new(
        attributes: {foo: 'fooval', bar: 'barval'},
        forms: [Yaks::Resource::Form.new(full_args)]
      )
    }

    subject {
      Yaks::Primitivize.create.call(described_class.new.call(resource))
    }

    context "template uses only required fields" do
      let(:full_args) {
        {
          name: :search,
          action: '/foo',
          method: 'GET'
        }
      }

      it 'should render the queries array' do
        should deep_eql(
          "collection" => {
            "version" => "1.0",
            "items" => [
              {
                "data" => [
                  { "name"=>"foo", "value"=>"fooval" },
                  { "name"=>"bar", "value"=>"barval" }
                ]
              }
            ],
            "queries" => [
              { "href"=>"/foo", "rel"=>"search" }
            ]
          }
        )
      end
    end

    context "template uses optional fields" do
      let(:fields) {
        [
          Yaks::Resource::Form::Field.new(name: 'foo', label: 'My Foo Field'),
          Yaks::Resource::Form::Field.new(name: 'bar', label: 'My Bar Field')
        ]
      }

      let(:full_args) {
        {
          name: :search,
          action: '/foo',
          method: 'GET',
          title: 'My query prompt',
          fields: fields
        }
      }

      it 'should render the queries array with optional fields' do
        should deep_eql(
          "collection" => {
            "version" => "1.0",
            "items" => [
              {
                "data" => [
                  { "name"=>"foo", "value"=>"fooval" },
                  { "name"=>"bar", "value"=>"barval" }
                ]
              }
            ],
            "queries" => [
              { "href"=>"/foo", "rel"=>"search", "prompt"=>"My query prompt",
                "data"=>
                [
                  { "name"=>"foo", "value"=>"", "prompt"=>"My Foo Field" },
                  { "name"=>"bar", "value"=>"", "prompt"=>"My Bar Field" }
                ]
              },
            ]
          }
        )
      end
    end
  end
end
