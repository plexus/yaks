require 'acceptance/models'
require 'acceptance/json_shared_examples'

RSpec.describe Yaks::Format::Hal do
  yaks_rel_template = Yaks.new do
    format_options :hal, plural_links: ['http://literature.example.com/rels/quotes']
    rel_template "http://literature.example.com/rel/{rel}"
  end

  yaks_policy_dsl = Yaks.new do
    format_options :hal, plural_links: ['http://literature.example.com/rels/quotes']
    derive_rel_from_association do |association|
      "http://literature.example.com/rel/#{association.name}"
    end
  end

  context  { include_examples 'JSON Writer', yaks_rel_template, :hal, 'confucius' }
  context  { include_examples 'JSON Writer', yaks_policy_dsl, :hal, 'confucius' }
  context  { include_examples 'JSON round trip', yaks_rel_template, :hal, 'confucius' }
  context  { include_examples 'JSON round trip', yaks_policy_dsl, :hal, 'confucius' }
  context  { include_examples 'JSON Writer', yaks_policy_dsl, :hal, 'list_of_quotes' }
  context  { include_examples 'JSON round trip', yaks_policy_dsl, :hal, 'list_of_quotes' }
end

RSpec.describe Yaks::Format::Halo do
  yaks = Yaks.new do
    default_format :halo
    rel_template "http://literature.example.com/rel/{rel}"
  end

  context { include_examples 'JSON Writer', yaks, :halo, 'confucius' }
end

RSpec.describe Yaks::Format::JsonAPI do
  context { include_examples 'JSON Writer', Yaks.new, :json_api, 'confucius' }
  # context { include_examples 'JSON Reader', Yaks.new, :json_api, 'confucius' }
  context { include_examples 'JSON round trip', Yaks.new, :json_api, 'confucius' }
  context { include_examples 'JSON Writer', Yaks.new, :json_api, 'list_of_quotes' }
  # context { include_examples 'JSON round trip', Yaks.new, :json_api, 'list_of_quotes' }
end

RSpec.describe Yaks::Format::CollectionJson do
  youtypeit_yaks = Yaks.new do
    mapper_namespace Youtypeitwepostit
  end

  context { include_examples 'JSON Writer', youtypeit_yaks, :collection_json, 'youtypeitwepostit' }
  context { include_examples 'JSON Writer', Yaks.new, :collection_json, 'confucius' }
  context { include_examples 'JSON Writer', Yaks.new, :collection_json, 'list_of_quotes' }
end
