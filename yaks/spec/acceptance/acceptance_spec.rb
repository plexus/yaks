require 'acceptance/models'
require 'acceptance/json_shared_examples'

RSpec.describe Yaks::Format::Hal do
  let(:format_name) { :hal }

  context 'with a configured rel template' do
    let(:yaks_config) {
      Yaks.new do
        format_options :hal, plural_links: ['http://literature.example.com/rels/quotes']
        rel_template "http://literature.example.com/rel/{rel}"
      end
    }

    include_examples 'JSON Writer',     'confucius'
    include_examples 'JSON round trip', 'confucius'
  end

  context 'with a rel computed by a policy override' do
    let(:yaks_config) {
      Yaks.new do
        format_options :hal, plural_links: ['http://literature.example.com/rels/quotes']
        derive_rel_from_association do |association|
          "http://literature.example.com/rel/#{association.name}"
        end
      end
    }

    include_examples 'JSON Writer',     'confucius'
    include_examples 'JSON round trip', 'confucius'
    include_examples 'JSON Writer',     'list_of_quotes'
    include_examples 'JSON round trip', 'list_of_quotes'
  end
end

RSpec.describe Yaks::Format::Halo do
  let(:format_name) { :halo }
  let(:yaks_config) {
    Yaks.new do
      default_format :halo
      rel_template "http://literature.example.com/rel/{rel}"
    end
  }

  include_examples 'JSON Writer', 'confucius'
end

RSpec.describe Yaks::Format::JsonAPI do
  let(:format_name) { :json_api }
  let(:yaks_config) { Yaks.new }

  include_examples 'JSON Writer', 'confucius'
  # include_examples 'JSON Reader', 'confucius'
  include_examples 'JSON round trip', 'confucius'
  include_examples 'JSON Writer', 'list_of_quotes'
  # include_examples 'JSON round trip', 'list_of_quotes'
end

RSpec.describe Yaks::Format::CollectionJson do
  let(:format_name) { :collection_json }
  let(:yaks_config) { Yaks.new }

  include_examples 'JSON Writer', 'confucius'
  include_examples 'JSON Writer', 'list_of_quotes'

  context 'with a namespace' do
    let(:yaks_config) {
      Yaks.new do
        mapper_namespace Youtypeitwepostit
      end
    }

    include_examples 'JSON Writer', 'youtypeitwepostit'
  end
end
