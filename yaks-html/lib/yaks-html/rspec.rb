require 'yaks-html'
require 'capybara/rspec'

module YaksHTML
  # This is a bit of a hack. The only way to add custom rack env
  # entries to Capybara/Rack::Test is through the driver options (see
  # Capybara.register_driver below). However this is only executed
  # once, so throughout the whole test suite the same instance of the
  # hash we pass will be used. To make it a bit easier to set/reset
  # this we add this layer of indirection. Now what we pass the driver
  # looks like a hash, but we can point it to a new hash with
  # RACK_ENV.__setobj__({})

  RACK_ENV = SimpleDelegator.new({})

  module CapybaraDSL
    def self.included(base)
      base.class_eval do
        let(:rel_prefix) { '' }
      end
    end

    def click_rel(rel)
      rel = [rel_prefix, rel].join unless rel.is_a? Symbol
      find("a[rel=\"#{rel}\"]").click
    end

    def click_first_rel(rel)
      rel = [rel_prefix, rel].join unless rel.is_a? Symbol
      all("a[rel=\"#{rel}\"]").first.click
    end

    def submit!
      find('input[type="submit"]').click
    end

    def within_form(name, &block)
      within(find_form(name), &block)
    end

    def submit_form(name, &block)
      within(find_form(name)) do
        yield block
        submit!
      end
    end

    def refresh
      visit current_path
    end

    def env
      YaksHTML::RACK_ENV
    end

    private

    def find_form(name)
      forms = all("form[@name=\"#{name}\"]")

      if forms.empty?
        fname = "/tmp/page-#{rand(999999999999999)}.html"
        File.write(fname, page.body)
        raise "No form found with name #{name}. Page saved as #{fname}"
      end

      forms.first
    end
  end
end

RSpec.configure do |config|
  select = {type: :yaks_integration}

  config.include Capybara::DSL, select
  config.include Capybara::RSpecMatchers, select

  config.include YaksHTML::CapybaraDSL, select

  config.before(select) do
    YaksHTML::RACK_ENV.__setobj__('HTTP_ACCEPT' => 'text/html')
  end
end

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, headers: YaksHTML::RACK_ENV)
end
