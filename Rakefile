require 'rubygems/package_task'

spec = Gem::Specification.load(Pathname.glob('*.gemspec').first.to_s)
Gem::PackageTask.new(spec).define

desc "Push gem to rubygems.org"
task :push => :gem do
  sh "git tag v#{Yaks::VERSION}"
  sh "git push --tags"
  sh "gem push pkg/yaks-#{Yaks::VERSION}.gem"
end
