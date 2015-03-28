#!/usr/bin/env ruby

require 'mutant'
require 'pry'

args = ["-Ilib", "-ryaks", "--use", "rspec", "Yaks*"]
env = Mutant::Env::Bootstrap.call(Mutant::CLI.call(args))

integration = env.config.integration

integration.setup
binding.pry if integration.all_tests.empty?

env.subjects.each do |subject|
  match_expression = subject.match_expressions.first
  subject_tests = integration.all_tests.select do |test|
    match_expression.prefix?(test.expression)
  end
  unless subject_tests.any?
    puts subject.identification
    exit if ARGV.include?("-1")
  end
end
