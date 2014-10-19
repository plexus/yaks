require 'yaks'
require 'yaks-html'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'yard'

def delegate_task(gem, task_name)
  task task_name do
    chdir gem.to_s do
      sh "rake", task_name.to_s
    end
  end
end

[:yaks, :"yaks-html"].each do |gem|
  namespace gem do
    desc 'Run rspec'
    delegate_task gem, :rspec

    desc 'Build gem'
    delegate_task gem, :gem

    desc 'Generate YARD docs'
    delegate_task gem, :yard
  end
end

desc "Push gem to rubygems.org"
task :push => ["yaks:gem", "yaks-html:gem"] do
  sh "git tag v#{Yaks::VERSION}"
  sh "git push --tags"
  sh "gem push pkg/yaks-#{Yaks::VERSION}.gem"
  sh "gem push pkg/yaks-html-#{Yaks::VERSION}.gem"
end

desc "Run all the tests"
task :rspec => ["yaks:rspec", "yaks-html:rspec"]

desc 'Run mutation tests'
delegate_task :yaks, :mutant
