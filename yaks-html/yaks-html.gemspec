# encoding: utf-8

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
  gem.files            = `git ls-files`.split($/)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = %w[README.md]

  gem.add_runtime_dependency 'yaks', Yaks::VERSION
  gem.add_runtime_dependency 'hexp', '>= 0.3'
end
