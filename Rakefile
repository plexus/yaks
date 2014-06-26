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
    # Yaks::Util,
    # Yaks::Primitivize,
    # Yaks::FP,
    # Yaks::Resource,
    # Yaks::NullResource,
    # Yaks::CollectionResource,
    # Yaks::Mapper::Association,
    # Yaks::Mapper::AssociationMapper,
    # Yaks::Mapper::HasMany,
    # Yaks::Mapper::HasOne,
    # Yaks::Mapper::Config,
    # Yaks::Mapper::ClassMethods,
    # Yaks::Mapper::Attribute,
    # Yaks::Format,
    # Yaks::Config::DSL,
    # Yaks::CollectionMapper,
    Yaks::DefaultPolicy,          # 45/249 (81.93%)
    Yaks::Mapper::Link,           # 37/284 (86.97%)
    Yaks::Format::CollectionJson, # 15/183 (91.80%)
    Yaks::Format::Hal,            # 17/209 (91.87%)
    Yaks::Mapper,                 # 12/203 (94.09%)
    Yaks::Config,                 # 12/263 (95.44%)
    Yaks::Format::JsonApi,        # 7/291  (97.59%)
  ].each do |space|
    puts space
    ENV['PATTERN'] = "#{space}"
    Rake::Task["mutant"].execute
  end
end
