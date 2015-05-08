RSpec.shared_examples_for 'JSON Writer' do |yaks, format, name|
  let(:object)  { load_yaml_fixture(name) }
  let(:expected) { load_json_fixture("#{name}.#{format}") }
  let(:serialized) { yaks.call(object, hooks: [[:skip, :serialize]], format: format) }

  # before do
  #   puts "============================expected=========================================="
  #   puts JSON.pretty_generate(expected)
  #   puts "=================yaks.call(object, format: #{format.inspect})================="
  #   puts JSON.pretty_generate(serialized)
  # end

  it do
    expect(serialized).to deep_eql expected
  end
end

RSpec.shared_examples_for 'JSON Reader' do |yaks, format, name|
  let(:object) { load_yaml_fixture(name) }
  let(:json) { load_json_fixture("#{name}.#{format}") }

  let(:resource) { yaks.read(json, hooks: [[:skip, :parse]], format: format) }

  it 'should read to a Resource' do
    expect(resource.pp).to eql yaks.map(object).pp
  end
end

RSpec.shared_examples_for 'JSON round trip' do |yaks, format, name|
  let(:json_fixture) { load_json_fixture("#{name}.#{format}") }

  let(:read_and_written) {
    config = yaks.with(default_format: format)
    config.format(config.read(json_fixture, hooks: [[:skip, :parse]]))
  }

  specify 'after reading the JSON to a Resource and writing it out again, it should be identical' do
    expect(read_and_written).to deep_eql json_fixture
  end

end
