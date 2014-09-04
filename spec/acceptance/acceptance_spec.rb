require 'spec_helper'

require 'acceptance/models'
require 'acceptance/json_shared_examples'

RSpec.describe Yaks::Format::Hal do
  yaks_rel_template = Yaks.new do
    format_options :hal, plural_links: ['http://literature.example.com/rels/quotes']
    rel_template "http://literature.example.com/rel/{association_name}"
    skip :serialize
  end

  yaks_policy_dsl = Yaks.new do
    format_options :hal, plural_links: ['http://literature.example.com/rels/quotes']
    derive_rel_from_association do |association|
      "http://literature.example.com/rel/#{association.name}"
    end
    skip :serialize
  end

  include_examples 'JSON output format' , yaks_rel_template , :hal , 'confucius'
  include_examples 'JSON output format' , yaks_policy_dsl   , :hal , 'confucius'
end

RSpec.describe Yaks::Format::JsonAPI do
  config = Yaks.new do
    default_format :json_api
    skip :serialize
  end

  include_examples 'JSON output format' , config , :json_api , 'confucius'
end

RSpec.describe Yaks::Format::CollectionJson do
  youtypeit_yaks = Yaks.new do
    default_format :collection_json
    namespace Youtypeitwepostit
    skip :serialize
  end

  confucius_yaks = Yaks.new do
    default_format :collection_json
    skip :serialize
  end

  include_examples 'JSON output format', youtypeit_yaks, :collection, 'youtypeitwepostit'
  include_examples 'JSON output format', confucius_yaks, :collection, 'confucius'
end
