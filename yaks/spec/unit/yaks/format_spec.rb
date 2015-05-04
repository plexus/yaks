RSpec.describe Yaks::Format do
  describe '.by_name' do
    specify do
      expect(Yaks::Format.by_name(:hal)).to eql Yaks::Format::Hal
    end
    specify do
      expect(Yaks::Format.by_name(:json_api)).to eql Yaks::Format::JsonAPI
    end
  end

  describe '.by_media_type' do
    specify do
      expect(Yaks::Format.by_media_type('application/hal+json')).to eql Yaks::Format::Hal
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

  describe '.media_types' do
    specify do
      expect(Yaks::Format.media_types.values_at(:collection_json, :hal, :json_api)).to eql(["application/vnd.collection+json", "application/hal+json", "application/vnd.api+json"])
    end
  end

  let(:init_opts) { Hash.new }
  subject(:format) { Yaks::Format.new(init_opts) }

  describe "#initialize" do
    it 'should set options' do
      expect(format.send(:options)).to equal init_opts
    end

    it 'should default to an empty hash' do
      expect(Yaks::Format.new.send(:options)).to eql({})
    end
  end

  describe "#call" do
    it 'should set the environment' do
      format.call(nil, foo: 1)
      expect(format.env).to eql(foo: 1)
    end

    it 'should default to an empty environment' do
      format.call(:foo)
      expect(format.env).to eql({})
    end

    it 'should delegate to #serialize_resource' do
      stub(format).serialize_resource(:foo) {|_r| :bar}
      expect(format.call(:foo)).to equal :bar
    end
  end

  describe '#serialize_resource' do
    specify { expect(format.serialize_resource(:foo)).to be_nil }
  end
end
