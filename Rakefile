require 'rubygems/package_task'

spec = Gem::Specification.load(Pathname.glob('*.gemspec').first.to_s)
Gem::PackageTask.new(spec).define

desc "Push gem to rubygems.org"
task :push => :gem do
  sh "git tag v#{Yaks::VERSION}"
  sh "git push --tags"
  sh "gem push pkg/yaks-#{Yaks::VERSION}.gem"
end

require 'mutant'
task :default => :mutant

task :mutant do
  pattern = ENV.fetch('PATTERN', 'Yaks*')
  result  = Mutant::CLI.run(%w[-Ilib -ryaks --use rspec --score 100] + [pattern])
  fail unless result == Mutant::CLI::EXIT_SUCCESS
end
