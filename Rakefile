require 'yaks'
require 'yaks-html'
require 'mutant'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'yard'

desc "Push gem to rubygems.org"
task :push => ["yaks:gem", "yaks-html:gem"] do
  sh "git tag v#{Yaks::VERSION}"
  sh "git push --tags"
  sh "gem push pkg/yaks-#{Yaks::VERSION}.gem"
  sh "gem push pkg/yaks-html-#{Yaks::VERSION}.gem"
end

def gem_tasks(gem)
  namespace gem do
    spec = Gem::Specification.load("#{gem}/#{gem}.gemspec")
    Gem::PackageTask.new(spec).define

    task :mutant do
      pattern = ENV.fetch('PATTERN', gem == :yaks ? 'Yaks*' : 'Yaks::Format::HTML*')
      opts    = ENV.fetch('MUTANT_OPTS', '').split(' ')
      Dir.chdir gem.to_s do
        result  = Mutant::CLI.run(%W[-Ilib -ryaks --use rspec --score 100] + opts + [pattern])
        fail unless result == Mutant::CLI::EXIT_SUCCESS
      end
    end

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
