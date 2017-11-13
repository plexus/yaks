source 'https://rubygems.org'

gemspec path: 'yaks'
gemspec path: 'yaks-html'
gemspec path: 'yaks-sinatra'

# Transit depends on Oj, which is not available for JRuby
unless defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
  gemspec path: 'yaks-transit'
end

if RUBY_VERSION < '2'
  gem 'mime-types', [ '>= 2.6.2', '< 3' ]
end

# gem 'mutant', github: 'mbj/mutant'
# gem 'mutant-rspec', github: 'mbj/mutant'
