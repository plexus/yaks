require 'yaks'
require 'yaks-html'
require 'yaks-sinatra'
require 'yaks-transit'

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'rubygems/package_task'
require 'yard'

def delegate_task(gem, task_name)
  task task_name do
    chdir gem.to_s do
      sh "rake", task_name.to_s
    end
  end
end

[:yaks, :"yaks-html", :"yaks-sinatra"].each do |gem|
  namespace gem do
    desc 'Run rspec'
    delegate_task gem, :rspec

    desc 'Build gem'
    delegate_task gem, :gem

    desc 'Generate YARD docs'
    delegate_task gem, :yard

    desc 'push gem to rubygems'
    task :push => "#{gem}:gem" do
      sh "gem push pkg/#{gem}-#{Yaks::VERSION}.gem"
    end
  end
end

desc "Tag current release and push to Github"
task :tag do
  sh "git tag v#{Yaks::VERSION}"
  sh "git push --tags"
end

desc "Tag, build, and push all gems to rubygems.org"
task :push_all => [
       :tag,
       "yaks:gem",
       "yaks-html:gem",
       "yaks-sinatra:gem",
       "yaks:push",
       "yaks-html:push",
       "yaks-sinatra:push"
     ]
task :push => :push_all

desc "Run all the tests"
task :rspec => ["yaks:rspec", "yaks-html:rspec", "yaks-sinatra:rspec"]

desc 'Run mutation tests'
delegate_task :yaks, :mutant

desc "Start a console"
task :console do
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end

task :ataru do
  require "ataru"
  Dir.chdir("yaks")
  Ataru::CLI::Application.start(["check", "README.md"])
end

RuboCop::RakeTask.new do |task|
  task.options << '--display-cop-names'
end

task :default => [:rspec, :rubocop]
