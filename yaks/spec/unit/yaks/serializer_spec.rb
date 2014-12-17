RSpec.describe Yaks::Serializer do
  after do
    Yaks::Serializer.instance_variable_set("@serializers", nil)
  end

  it 'allows registering serializers' do
    Yaks::Serializer.register(:some_format, :some_serializer)
    expect(Yaks::Serializer.all[:some_format]).to equal :some_serializer
  end

  it 'should by default have a serializer for JSON' do
    expect(Yaks::Serializer.all[:json].call([1,2,3], {})).to eql "[\n  1,\n  2,\n  3\n]"
  end

  it 'should warn when registering a key again' do
    expect { Yaks::Serializer.register(:json, :foo) }.to raise_exception /Serializer for json already registered/
  end
end
