require 'spec_helper'

RSpec.describe Yaks::Serializer do
  describe '.by_name' do
    specify { expect(Yaks::Serializer.by_name(:hal)).to eql Yaks::Serializer::Hal }
    specify { expect(Yaks::Serializer.by_name(:json_api)).to eql Yaks::Serializer::JsonApi }
  end

  describe '.by_mime_type' do
    specify { expect(Yaks::Serializer.by_mime_type('application/hal+json')).to eql Yaks::Serializer::Hal }
  end
end
