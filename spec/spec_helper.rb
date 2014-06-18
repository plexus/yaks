require 'rspec/its'

require 'yaks'
require 'virtus'

require 'fixture_helpers'

require_relative 'support/models'
require_relative 'support/pet_mapper'
require_relative 'support/pet_peeve_mapper'
require_relative 'support/friends_mapper'
require_relative 'support/fixtures'
require_relative 'support/shared_contexts'
require_relative 'support/youtypeit_models_mappers'
require_relative 'support/deep_eql'


RSpec.configure do |rspec|
  rspec.include FixtureHelpers
  rspec.backtrace_exclusion_patterns = [] if ENV['FULLSTACK']
  #rspec.disable_monkey_patching!
  rspec.raise_errors_for_deprecations!
end
