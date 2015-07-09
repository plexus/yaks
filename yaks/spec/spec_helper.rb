require 'yaks'
require 'yaks-html'
require 'virtus'

require_relative '../../shared/rspec_config'

require 'fixture_helpers'

RSpec.configure do |rspec|
  rspec.include FixtureHelpers
end

Bogus.configure do |bogus|
  bogus.search_modules << Yaks
  bogus.search_modules << Yaks::Mapper
end

require_relative 'support/models'
require_relative 'support/pet_mapper'
require_relative 'support/pet_peeve_mapper'
require_relative 'support/friends_mapper'
require_relative 'support/fixtures'
require_relative 'support/shared_contexts'
require_relative 'support/youtypeit_models_mappers'
require_relative 'support/deep_eql'
require_relative 'support/classes_for_policy_testing'
