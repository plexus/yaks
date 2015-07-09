require 'rspec/its'
require 'bogus/rspec'
require 'timeout'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

RSpec.configure do |rspec|
  # Set the FULLSTACK environment variable to prevent RSpec from
  # filtering stack traces. This can be useful to debug errors that
  # happen inside third party libraries
  rspec.backtrace_exclusion_patterns = [] if ENV['FULLSTACK']

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  rspec.disable_monkey_patching!

  # Make sure we stay up to date
  rspec.raise_errors_for_deprecations!

  rspec.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # This is configured for us by including bogus/rspec. We do not include rspec-mocks.
  # rspec.mock_with :bogus

  # Mutated code can lead to infinite loops. Consider tests that run
  # too long as having failed
  if defined?(Mutant)
    rspec.around(:each) do |example|
      Timeout.timeout(1, &example)
    end
  end
end
