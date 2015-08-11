# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pad/version'

Gem::Specification.new do |spec|
  spec.name          = 'pad'
  spec.version       = Pad::VERSION
  spec.authors       = ['Declan Whelan']
  spec.email         = ['declan@pleanintuit.com']
  spec.summary       = 'A light weight framework for supporting Ports & Adapters designs with Domain Driven Design'
  spec.description   = 'A light weight framework for supporting Ports & Adapters designs with Domain Driven Design'
  spec.homepage      = 'https://github.com/dwhelan/pad'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'virtus', '~> 1.0'

  spec.add_development_dependency 'bundler', '         ~>  1.7'
  spec.add_development_dependency 'rake',             '~> 10.0'
  spec.add_development_dependency 'rspec',            '~>  3.0'
  spec.add_development_dependency 'shoulda-matchers', '~>  2.8'
end
