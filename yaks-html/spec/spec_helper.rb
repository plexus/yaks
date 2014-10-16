RSpec.configure do |rspec|
  rspec.include FixtureHelpers
  rspec.backtrace_exclusion_patterns = [] if ENV['FULLSTACK']
  rspec.disable_monkey_patching!
  rspec.raise_errors_for_deprecations!
end
