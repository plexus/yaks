require 'spec_helper'

RSpec.describe Yaks::Format::Hal do
  include_context 'plant collection resource'

  subject { Yaks::Primitivize.create.call(described_class.new.call(resource)) }

  it { should eq(load_json_fixture('hal_plant_collection')) }
end
