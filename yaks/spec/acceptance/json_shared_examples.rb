RSpec.shared_examples_for 'JSON output format' do |yaks, format, name|
  let(:input)  { load_yaml_fixture(name) }
  let(:output) { load_json_fixture("#{name}.#{format}") }

  subject { yaks.call(input) }

  it { should deep_eql output }
end

RSpec.shared_examples_for 'JSON round trip' do |yaks, format, name|
  let(:json) { load_json_fixture("#{name}.#{format}") }

  subject {
    resource = yaks.read(json, hooks: [[:skip, :parse]])
    yaks.call(resource, hooks: [[:skip, :map]], mapper: Struct.new(:context))
  }

  it { should deep_eql json }
end
