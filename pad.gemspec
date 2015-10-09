# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pad/version'

Gem::Specification.new do |gem|
  gem.name          = 'pad'
  gem.version       = Pad::VERSION
  gem.authors       = ['Declan Whelan']
  gem.email         = ['declan@pleanintuit.com']
  gem.summary       = 'A light weight framework for supporting Ports & Adapters designs with Domain Driven Design'
  gem.description   = 'A light weight framework for supporting Ports & Adapters designs with Domain Driven Design'
  gem.homepage      = 'https://github.com/dwhelan/pad'
  gem.license       = 'MIT'

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'virtus', '~> 1.0'

  gem.add_development_dependency 'attribute_matcher', '~>  0.2'
  gem.add_development_dependency 'bundler',           '~>  1.7'
  gem.add_development_dependency 'coveralls',         '~>  0.7'
  gem.add_development_dependency 'delegate_matcher',  '~>  0.0'
  gem.add_development_dependency 'guard',             '~>  2.13'
  gem.add_development_dependency 'guard-rspec',       '~>  4.6'
  gem.add_development_dependency 'rake',              '~> 10.0'
  gem.add_development_dependency 'rspec',             '~>  3.0'
  gem.add_development_dependency 'rspec-its',         '~>  1.1'
  gem.add_development_dependency 'rubocop',           '~>  0.30'
end
