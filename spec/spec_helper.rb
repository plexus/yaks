require 'pathname'

ROOT = Pathname(__FILE__).join('../..')

$LOAD_PATH.unshift(ROOT.join('lib'))

require 'yaks'
require 'virtus'
require 'json'

require_relative 'support/models'
require_relative 'support/pet_mapper'
require_relative 'support/pet_peeve_mapper'
require_relative 'support/friends_mapper'
require_relative 'support/fixtures'
require_relative 'support/shared_contexts'
require_relative 'support/youtypeit_models_mappers'

def load_json_fixture(name)
  JSON.parse(ROOT.join('spec/json', name + '.json').read)
end

def load_yaml_fixture(name)
  YAML.load(ROOT.join('spec/yaml', name + '.yaml').read)
end

RSpec.configure do |rspec|
  rspec.backtrace_exclusion_patterns = [] if ENV['FULLSTACK']
end
