# encoding: utf-8

require 'English'
require File.expand_path('../../yaks/lib/yaks/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'yaks-sinatra'
  gem.version     = Yaks::VERSION
  gem.authors     = [ 'Arne Brasseur' ]
  gem.email       = [ 'arne@arnebrasseur.net' ]
  gem.description = 'Sinatra integration for Yaks'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/plexus/yaks'
  gem.license     = 'MIT'

  gem.require_paths    = %w[lib]
  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = %w[README.md]

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_runtime_dependency 'yaks', Yaks::VERSION
  gem.add_runtime_dependency 'sinatra', '>= 1.4', "< 2.1"
  gem.add_development_dependency 'rack-test', '~> 0.6'
end
