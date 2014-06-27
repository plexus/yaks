require 'spec_helper'

require 'acceptance/models'
require 'acceptance/json_shared_examples'

RSpec.describe Yaks::Format::Hal do
  yaks_rel_template = Yaks.new do
    format_options :hal, plural_links: ['http://literature.example.com/rels/quotes']
    rel_template "http://literature.example.com/rel/{association_name}"
  end

  yaks_policy_dsl = Yaks.new do
    format_options :hal, plural_links: ['http://literature.example.com/rels/quotes']
    derive_rel_from_association do |mapper, association|
      "http://literature.example.com/rel/#{association.name}"
    end
  end

  include_examples 'JSON output format' , yaks_rel_template , :hal , 'confucius'
  include_examples 'JSON output format' , yaks_policy_dsl   , :hal , 'confucius'
end

RSpec.describe Yaks::Format::JsonApi do
  config = Yaks.new do
    default_format :json_api
  end

  include_examples 'JSON output format' , config , :json_api , 'confucius'
end

RSpec.describe Yaks::Format::CollectionJson do
  config = Yaks.new do
    default_format :collection_json
    mapper_namespace Youtypeitwepostit
  end

  include_examples 'JSON output format' , config , :collection , 'youtypeitwepostit'
end
