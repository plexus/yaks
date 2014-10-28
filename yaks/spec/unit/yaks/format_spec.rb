require 'spec_helper'

RSpec.describe Yaks::Format do
  describe '.by_name' do
    specify do
      expect(Yaks::Format.by_name(:hal)).to eql Yaks::Format::Hal
    end
    specify do
      expect(Yaks::Format.by_name(:json_api)).to eql Yaks::Format::JsonAPI
    end
  end

  describe '.by_mime_type' do
    specify do
      expect(Yaks::Format.by_mime_type('application/hal+json')).to eql Yaks::Format::Hal
    end
  end

  describe '.by_accept_header' do
    specify do
      expect(Yaks::Format.by_accept_header('application/hal+json;q=0.8, application/vnd.api+json')).to eql Yaks::Format::JsonAPI
    end
    specify do
      expect(Yaks::Format.by_accept_header('application/hal+json;q=0.8, application/vnd.api+json;q=0.7')).to eql Yaks::Format::Hal
    end
  end

  describe '.mime_types' do
    specify do
      expect(Yaks::Format.mime_types.values_at(:collection_json, :hal, :json_api)).to eql(["application/vnd.collection+json", "application/hal+json", "application/vnd.api+json"])
    end
  end
end
