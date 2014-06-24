require 'rubygems/package_task'
require 'yaks'

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
  opts    = ENV.fetch('MUTANT_OPTS', '').split(' ')
  result  = Mutant::CLI.run(%w[-Ilib -ryaks --use rspec --score 100] + opts + [pattern])
  fail unless result == Mutant::CLI::EXIT_SUCCESS
end

task :mutant_chunked do
  [
    #Yaks::Util,
    #Yaks::Primitivize,
    #Yaks::FP,
    #Yaks::Resource,
    #Yaks::NullResource,
    #Yaks::CollectionResource,
    Yaks::Mapper,
    Yaks::CollectionMapper,
    Yaks::Serializer,
    Yaks::Config,
    Yaks::DefaultPolicy
  ].each do |space|
    puts space
    ENV['PATTERN'] = "#{space}*"
    Rake::Task["mutant"].execute
  end
end
