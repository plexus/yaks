require 'spec_helper'

RSpec.describe Yaks::Format do
  describe '.by_name' do
    specify { expect(Yaks::Format.by_name(:hal)).to eql Yaks::Format::Hal }
    specify { expect(Yaks::Format.by_name(:json_api)).to eql Yaks::Format::JsonApi }
  end

  describe '.by_mime_type' do
    specify { expect(Yaks::Format.by_mime_type('application/hal+json')).to eql Yaks::Format::Hal }
  end
end
