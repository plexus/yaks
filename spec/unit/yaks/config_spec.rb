require 'spec_helper'

RSpec.describe Yaks::Config do
  include_context 'fixtures'

  def self.configure(&blk)
    subject(:config) { described_class.new(&blk) }
  end

  context 'defaults' do
    configure {}

    its(:default_format) { should equal :hal }
    its(:policy_class)   { should < Yaks::DefaultPolicy }

    it 'should have empty format options' do
      expect(config.options_for_format(:hal)).to eql({})
    end
  end

  context 'with a default format' do
    configure do
      default_format :json_api
    end

    its(:default_format) { should equal :json_api }
  end

  context 'with a custom policy class' do
    MyPolicy = Struct.new(:options)
    configure do
      policy MyPolicy
    end

    its(:policy_class) { should equal MyPolicy }
    its(:policy)       { should be_a  MyPolicy }
  end

  context 'with a rel template' do
    configure do
      rel_template 'http://rel/foo'
    end

    its(:policy_options) { should eql(rel_template: 'http://rel/foo') }
  end

  context 'with format options' do
    configure do
      format_options :hal, plural_links: [:self, :profile]
    end

    specify do
      expect(config.options_for_format(:hal)).to eql(plural_links: [:self, :profile])
    end
  end

  describe '#serialize' do
    configure do
      rel_template 'http://api.mysuperfriends.com/{association_name}'
      format_options :hal, plural_links: [:copyright]
    end

    specify do
      expect(config.serialize(john)).to eql(load_json_fixture 'john.hal')
    end
  end

  describe '#mapper_namespace' do
    module MyMappers
      class PetMapper < Yaks::Mapper
      end
    end

    configure do
      mapper_namespace MyMappers
    end

    specify do
      expect(config.policy.derive_mapper_from_object(boingboing)).to eql(MyMappers::PetMapper)
    end
  end

  describe '#map_to_primitive' do
    class TheMapper < Yaks::Mapper
      attributes :a_date
    end

    TheModel = Struct.new(:a_date)

    configure do
      map_to_primitive Date do |object|
        object.iso8601
      end
    end

    let(:model) {
      TheModel.new(Date.new(2014, 5, 6))
    }

    specify do
      expect(config.serialize(model, mapper: TheMapper)).to eq({"a_date"=>"2014-05-06"})
    end
  end

  context 'passing in a rack env' do
    configure do
      default_format :collection_json
    end

    let(:rack_env) {
      { 'HTTP_ACCEPT' => 'application/hal+json;q=0.8, application/vnd.api+json' }
    }

    it 'should detect serializer based on accept header' do
      rack_env = { 'HTTP_ACCEPT' => 'application/hal+json;q=0.8, application/vnd.api+json' }
      expect(config.serializer_class({}, rack_env)).to equal Yaks::Serializer::JsonApi
    end

    it 'should know to pick the best match' do
      rack_env = { 'HTTP_ACCEPT' => 'application/hal+json;q=0.8, application/vnd.api+json;q=0.7' }
      expect(config.serializer_class({}, rack_env)).to equal Yaks::Serializer::Hal
    end

    it 'should fall back to the default when no mime type is recognized' do
      rack_env = { 'HTTP_ACCEPT' => 'text/html, application/json' }
      expect(config.serializer_class({}, rack_env)).to equal Yaks::Serializer::CollectionJson
    end
  end
end
