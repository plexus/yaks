require 'spec_helper'
require 'yaml'
require 'json'

require_relative './models'

PATH = Pathname(__FILE__).dirname

hal = Yaks.new do
  format :hal
end

shared_examples_for 'JSON output format' do |yaks, name|
  let(:input)  { YAML.load IO.read PATH.join("input/#{name}.yaml") }
  let(:output) { JSON.load IO.read PATH.join("output/#{name}.json") }

  subject { yaks.serialize(input) }

  it { should eql output }
end

describe 'Acceptance test' do
  hal = Yaks.new do
    format :hal
    policy do
      def derive_rel_from_association(mapper, association)
        mapper_name = derive_key_from_mapper(mapper)
        "http://literature.example.com/rel/#{association.name}"
      end
    end
  end

  include_examples 'JSON output format', hal, 'confucius'
end
