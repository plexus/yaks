# encoding: utf-8

require File.expand_path('../lib/yaks/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'yaks'
  gem.version     = Yaks::VERSION
  gem.authors     = [ 'Arne Brasseur' ]
  gem.email       = [ 'arne@arnebrasseur.net' ]
  gem.description = 'Serialize to JSON-API and similar'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/plexus/yaks'
  gem.license     = 'MIT'

  gem.require_paths    = %w[lib]
  gem.files            = `git ls-files`.split($/)
  gem.test_files       = `git ls-files -- spec`.split($/)
  gem.extra_rdoc_files = %w[README.md]

  gem.add_runtime_dependency 'inflection'   , '~> 1.0'
  gem.add_runtime_dependency 'concord'      , '~> 0.1.4'
  gem.add_runtime_dependency 'uri_template' , '~> 0.6.0'

  gem.add_development_dependency 'virtus'
  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'mutant-rspec'
end
