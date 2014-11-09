RSpec.shared_examples_for 'JSON output format' do |yaks, format, name|
  let(:input)  { load_yaml_fixture(name) }
  let(:output) { load_json_fixture("#{name}.#{format}") }

  subject { yaks.call(input) }

  it { should deep_eql output }
end
