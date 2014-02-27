# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stockroll/version'

Gem::Specification.new do |spec|
  spec.name          = "stockroll"
  spec.version       = Stockroll::VERSION
  spec.authors       = ["Robot Jiang"]
  spec.email         = ["robot.z.jiang@gmail.com"]
  spec.description   = %q{To show real-time stock quotes.}
  spec.summary       = %q{To show real-time stock quotes.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ['stock']#spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
	spec.add_development_dependency "rspec"
	spec.add_dependency "thor"
	spec.add_dependency "colorize"
	spec.add_dependency "em-http-request"
	spec.add_dependency "curses"
end
