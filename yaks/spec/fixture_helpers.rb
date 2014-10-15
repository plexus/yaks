require 'yaml'
require 'json'

module FixtureHelpers
  module_function

  def load_json_fixture(name)
    JSON.parse(Yaks::Root.join('spec/json', name + '.json').read)
  end

  def load_yaml_fixture(name)
    YAML.load(Yaks::Root.join('spec/yaml', name + '.yaml').read)
  end
end
