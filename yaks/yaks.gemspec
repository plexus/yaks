# encoding: utf-8

require 'English'
require File.expand_path('../lib/yaks/version', __FILE__)
require File.expand_path('../lib/yaks/breaking_changes', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'yaks'
  gem.version     = Yaks::VERSION
  gem.authors     = [ 'Arne Brasseur' ]
  gem.email       = [ 'arne@arnebrasseur.net' ]
  gem.description = 'Serialize to hypermedia. HAL, JSON-API, etc.'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/plexus/yaks'
  gem.license     = 'MIT'

  gem.require_paths    = %w(lib)
  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = %w(README.md)

  if Yaks::BreakingChanges.key? Yaks::VERSION
    gem.post_install_message = Yaks::BreakingChanges[Yaks::VERSION]
  end

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_runtime_dependency 'abstract_type', '~> 0.0.7'
  gem.add_runtime_dependency 'adamantium',    '~> 0.2.0'
  gem.add_runtime_dependency 'anima',         '~> 0.2.0'
  gem.add_runtime_dependency 'attribs',       '~> 1.0'
  gem.add_runtime_dependency 'concord',       '~> 0.1.4'
  gem.add_runtime_dependency 'inflection',    '~> 1.0'
  gem.add_runtime_dependency 'rack-accept',   '~> 0.4.5'
  gem.add_runtime_dependency 'uri_template',  '~> 0.6.0'

  gem.add_development_dependency 'ataru'
  gem.add_development_dependency 'benchmark-ips'
  gem.add_development_dependency 'bogus'
  gem.add_development_dependency 'hamster'
  gem.add_development_dependency 'mutant'
  gem.add_development_dependency 'mutant-rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'virtus'
  gem.add_development_dependency 'yaks-html'
  gem.add_development_dependency 'yard'
end
