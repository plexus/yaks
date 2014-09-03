require 'spec_helper'

RSpec.describe Yaks::Runner do

  describe '#format_class' do
    let(:config) do
      Yaks::Config.new do
        default_format :collection_json
      end
    end

    let(:rack_env) {
      { 'HTTP_ACCEPT' => 'application/hal+json;q=0.8, application/vnd.api+json' }
    }


    it 'should fall back to the default when no HTTP_ACCEPT key is present' do
      runner = described_class.new(object: nil, config: config, options: { env: {} })
      expect(runner.format_class).to equal Yaks::Format::CollectionJson
    end

    it 'should detect format based on accept header' do
      rack_env = { 'HTTP_ACCEPT' => 'application/hal+json;q=0.8, application/vnd.api+json' }
      runner = described_class.new(object: nil, config: config, options: { env: rack_env })
      expect(runner.format_class).to equal Yaks::Format::JsonAPI
    end

    it 'should know to pick the best match' do
      rack_env = { 'HTTP_ACCEPT' => 'application/hal+json;q=0.8, application/vnd.api+json;q=0.7' }
      runner = described_class.new(object: nil, config: config, options: { env: rack_env })
      expect(runner.format_class).to equal Yaks::Format::Hal
    end

    it 'should fall back to the default when no mime type is recognized' do
      rack_env = { 'HTTP_ACCEPT' => 'text/html, application/json' }
      runner = described_class.new(object: nil, config: config, options: { env: rack_env })
      expect(runner.format_class).to equal Yaks::Format::CollectionJson
    end
  end
end
