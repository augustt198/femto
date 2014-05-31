# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'femto/version'

Gem::Specification.new do |spec|
  spec.name          = "femto"
  spec.version       = Femto::VERSION
  spec.authors       = ["August"]
  spec.email         = ["augustt198@gmail.com"]
  spec.description   = %q{A tiny web framework}
  spec.summary       = %q{A tiny web framework}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency 'rack', '~> 1.4.5'
  spec.add_dependency 'tilt', '~> 2.0.1'
  spec.add_dependency 'haml', '~> 4.0.4'
  spec.add_dependency 'mongo', '~> 1.10.0'
end
