RSpec.shared_examples_for 'JSON Writer' do |fixture_name|
  describe 'Yaks::Resource => JSON' do
    let(:object) { load_yaml_fixture(fixture_name) }
    let(:json_fixture) { load_json_fixture("#{fixture_name}.#{format_name}") }
    let(:serialized) {
      yaks_config.call(object, hooks: [[:skip, :serialize]], format: format_name)
    }

    # before do
    #   puts "============================expected========================================="
    #   puts JSON.pretty_generate(expected)
    #   puts "=================yaks.call(object, format: #{format.inspect})================"
    #   puts JSON.pretty_generate(serialized)
    # end

    it 'should match the JSON fixture' do
      expect(serialized).to deep_eql json_fixture
    end
  end
end

RSpec.shared_examples_for 'JSON Reader' do |fixture_name|
  describe 'JSON => Yaks::Resource' do
    let(:object) { load_yaml_fixture(fixture_name) }
    let(:json_fixture) { load_json_fixture("#{fixture_name}.#{format_name}") }
    let(:resource) {
      yaks_config.read(json_fixture, hooks: [[:skip, :parse]], format: format_name)
    }

    it 'should equal the corresponding Yaks::Resource' do
      # Comparing type+to_h to get better RSpec output upon failure
      expect(resource).to be_a Yaks::Resource
      expect(resource.to_h).to eql yaks.map(object).to_h
    end
  end
end

RSpec.shared_examples_for 'JSON round trip' do |fixture_name|
  describe 'JSON => Yaks::Resource => JSON' do
    let(:json_fixture) { load_json_fixture("#{fixture_name}.#{format_name}") }
    let(:read_and_written) {
      config = yaks_config.with(default_format: format_name)
      config.format(
        config.read(json_fixture, hooks: [[:skip, :parse]])
      )
    }

    specify 'it should be identical' do
      expect(read_and_written).to deep_eql json_fixture
    end
  end
end
