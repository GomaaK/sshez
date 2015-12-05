# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sshez/version'

Gem::Specification.new do |spec|
  spec.name          = "sshez"
  spec.version       = Sshez::VERSION
  spec.authors       = ["Immortal Friday"]
  spec.email         = ["khaled.gomaa.90@gmail.com"]

  spec.summary       = %q{Easy ssh config handling}
  spec.description   = %q{will interface your ssh config file
    Allowing you to add aliases to your server and do a lot of cool stuff}
  spec.homepage      = "https://github.com/GomaaK/sshez"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = ["sshez"] 
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

end
