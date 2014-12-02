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
        forms: [Yaks::Resource::Form.new(name: :queries, fields: fields)]
      )
    }

    subject {
      Yaks::Primitivize.create.call(described_class.new.call(resource))
    }

    context "template uses only required fields" do
      # NOTE: Yaks::Resource::Form::Field requires a name attr.
      # However, in CJ 'queries', 'name' is optional.
      # So here we're testing only required fields, but 'name'
      # shouldn't really be one of them… Leaving it this way for now.
      let(:fields) {
        [
          Yaks::Resource::Form::Field.new(name: 'foo', options: {rel: 'foo_rel', uri: 'my_foo_uri'}),
          Yaks::Resource::Form::Field.new(name: 'bar', options: {rel: 'bar_rel', uri: 'my_bar_uri'})
        ]
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
              { "href"=>"my_foo_uri", "rel"=>"foo_rel", "name"=>"foo" },
              { "href"=>"my_bar_uri", "rel"=>"bar_rel", "name"=>"bar" }
            ]
          }
        )
      end
    end

    context "template uses optional fields" do
      let(:fields) {
        [
          Yaks::Resource::Form::Field.new(name: 'foo', label: 'My Foo Field', options: {
            rel: 'foo_rel',
            uri: 'my_foo_uri'
            }),
          Yaks::Resource::Form::Field.new(name: 'bar', label: 'My Bar Field', options: {
            rel: 'bar_rel',
            uri: 'my_bar_uri',
            data: [{name: 'bar_data_name', value: 'bar_data_value'}]
            })
        ]
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
              { "href"=>"my_foo_uri", "rel"=>"foo_rel", "name"=>"foo", "prompt"=>"My Foo Field" },
              { "href"=>"my_bar_uri", "rel"=>"bar_rel", "name"=>"bar", "prompt"=>"My Bar Field", 
                "data"=>
                [
                  { "name"=>"bar_data_name", "value"=>"bar_data_value" }
                ]
              },
            ]
          }
        )
      end
    end
  end
end
