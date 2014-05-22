# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metricity-server/version'

Gem::Specification.new do |gem|
  gem.name          = 'metricity-server'
  gem.version       = Metricity::Server::VERSION
  gem.authors       = ['VvanGemert']
  gem.email         = ['vincent@floorplanner.com']
  gem.description   = 'Metricity Server'
  gem.summary       = ''
  gem.homepage      = ''
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($RS)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'eventmachine'
  gem.add_dependency 'json'
  gem.add_dependency 'mongo'
  gem.add_dependency 'bson_ext'
  gem.add_dependency 'sinatra'
  gem.add_dependency 'slim'
  gem.add_dependency 'sass'
  gem.add_dependency 'coffee-script'

  gem.add_development_dependency 'bundler', '~> 1.6'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-minitest'
  gem.add_development_dependency 'guard-rubocop'
end
