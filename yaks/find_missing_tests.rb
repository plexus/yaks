#!/usr/bin/env ruby

require 'mutant'
require 'pry'

# These are private methods that are tested by other methods in the same class
SKIP=%w[
Yaks::CollectionMapper#collection_rel
Yaks::CollectionMapper#collection_type
Yaks::CollectionMapper#mapper_for_model
Yaks::Resource::Form::Field#select_options_for_value
Yaks::Mapper::AssociationMapper#add_link
Yaks::Mapper::AssociationMapper#add_subresource
Yaks::Mapper::Link#resource_link_options

]

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
  unless subject_tests.any? || SKIP.include?(subject.expression.syntax)
    puts subject.identification
    exit if ARGV.include?("-1")
  end
end
