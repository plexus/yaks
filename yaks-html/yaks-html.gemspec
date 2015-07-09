# encoding: utf-8

require 'English'
require File.expand_path('../../yaks/lib/yaks/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'yaks-html'
  gem.version     = Yaks::VERSION
  gem.authors     = [ 'Arne Brasseur' ]
  gem.email       = [ 'arne@arnebrasseur.net' ]
  gem.description = 'HTML output format for Yaks'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/plexus/yaks'
  gem.license     = 'MIT'

  gem.require_paths    = %w[lib]
  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = %w[README.md]

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_runtime_dependency 'yaks', Yaks::VERSION
  gem.add_runtime_dependency 'hexp', '>= 0.4'

  gem.add_development_dependency 'yaks-sinatra'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'capybara'
end
