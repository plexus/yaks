require 'spec_helper'
require 'yaml'
require 'json'

require_relative './models'

shared_examples_for 'JSON output format' do |yaks, name|
  let(:input)  { load_yaml_fixture name }
  let(:output) { load_json_fixture name }

  subject { yaks.serialize(input) }

  it { should eql output }
end

describe 'Acceptance test' do
  yaks_rel_template = Yaks.new do
    rel_template "http://literature.example.com/rel/{association_name}"
  end

  yaks_policy_dsl = Yaks.new do
    derive_rel_from_association do |mapper, association|
      "http://literature.example.com/rel/#{association.name}"
    end
  end

  yaks_policy_override = Yaks.new do
    policy do
      def derive_rel_from_association(mapper, association)
        "http://literature.example.com/rel/#{association.name}"
      end
    end
  end

  include_examples 'JSON output format', yaks_rel_template, 'confucius'
  include_examples 'JSON output format', yaks_policy_dsl,   'confucius'
  include_examples 'JSON output format', yaks_policy_override,   'confucius'
end
