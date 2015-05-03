require 'yaks'
require 'yaks-html'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'yard'

def mutant_task(gem)
  require 'mutant'
  task :mutant do
    pattern = ENV.fetch('PATTERN', 'Yaks*')
    opts    = ENV.fetch('MUTANT_OPTS', '').split(' ')
    args    = %w[-Ilib -ryaks --use rspec --score 100] + opts + [pattern]
    result  = Mutant::CLI.run(args)
    fail unless result == Mutant::CLI::EXIT_SUCCESS
  end
end

def gem_tasks(gem)
  Gem::PackageTask.new(Gem::Specification.load("#{gem}.gemspec")) do |task|
    task.package_dir = '../pkg'
  end

  mutant_task(gem) if RUBY_ENGINE == 'ruby'

  RSpec::Core::RakeTask.new(:rspec) do |t, _task_args|
    t.rspec_opts = "-Ispec"
    t.pattern = "spec"
  end

  YARD::Rake::YardocTask.new do |t|
    t.files   = ["lib/**/*.rb" "**/*.md"]
    t.options = %w[--output-dir ../doc]
  end
end
