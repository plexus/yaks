require 'yaks'
require 'yaks-html'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'yard'

def mutant_task(gem)
  require 'mutant'
  task :mutant do
    pattern = ENV.fetch('PATTERN', gem == :yaks ? 'Yaks*' : 'Yaks::Format::HTML*')
    opts    = ENV.fetch('MUTANT_OPTS', '').split(' ')
    Dir.chdir gem.to_s do
      result  = Mutant::CLI.run(%W[-Ilib -ryaks --use rspec --score 100] + opts + [pattern])
      fail unless result == Mutant::CLI::EXIT_SUCCESS
    end
  end
end

def gem_tasks(gem)
  namespace gem do
    Gem::PackageTask.new(Gem::Specification.load("#{gem}/#{gem}.gemspec")).define

    mutant_task(gem) if RUBY_ENGINE == 'ruby'

    RSpec::Core::RakeTask.new(:rspec) do |t, task_args|
      t.rspec_opts = "-I#{gem}/spec"
      t.pattern = "#{gem}/spec"
    end

    YARD::Rake::YardocTask.new do |t|
      t.files   = ["#{gem}/lib/**/*.rb" "#{gem}/**/*.md"]
    end
  end
end

gem_tasks(:yaks)
gem_tasks(:"yaks-html")

desc "Push gem to rubygems.org"
task :push => ["yaks:gem", "yaks-html:gem"] do
  sh "git tag v#{Yaks::VERSION}"
  sh "git push --tags"
  sh "gem push pkg/yaks-#{Yaks::VERSION}.gem"
  sh "gem push pkg/yaks-html-#{Yaks::VERSION}.gem"
end
