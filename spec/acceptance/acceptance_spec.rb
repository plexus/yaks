require 'spec_helper'
require 'yaml'
require 'json'

require_relative './models'

shared_examples_for 'JSON output format' do |yaks, format, name|
  let(:input)  { load_yaml_fixture name }
  let(:output) { load_json_fixture "#{name}.#{format}" }

  subject { yaks.serialize(input) }

  it { should eql output }
end

describe Yaks::HalSerializer do
  yaks_rel_template = Yaks.new do
    rel_template "http://literature.example.com/rel/{association_name}"
  end

  yaks_policy_dsl = Yaks.new do
    derive_rel_from_association do |mapper, association|
      "http://literature.example.com/rel/#{association.name}"
    end
  end

  include_examples 'JSON output format' , yaks_rel_template    , :hal      , 'confucius'
  include_examples 'JSON output format' , yaks_policy_dsl      , :hal      , 'confucius'
end

describe Yaks::JsonApiSerializer do
  config = Yaks.new do
    default_format :json_api
  end

  include_examples 'JSON output format' , config , :json_api , 'confucius'
end
