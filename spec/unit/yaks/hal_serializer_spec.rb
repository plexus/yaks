require 'spec_helper'

describe Yaks::HalSerializer do
  include_context 'plant collection resource'

  subject { Yaks::Primitivize.create.call(described_class.new(resource).serialize) }

  it { should eq(load_json_fixture('hal_plant_collection')) }
end