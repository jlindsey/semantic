require File.join(File.dirname(__FILE__), 'lib/semantic')

Gem::Specification.new do |s|
  s.name          = "semantic"
  s.version       = Semantic::GEM_VERSION
  s.authors       = ["Josh Lindsey"]
  s.email         = ["josh@core-apps.com"]
  s.homepage      = "https://github.com/jlindsey/semantic"
  s.summary       = %q{Semantic Version utility class}
  s.description   = %q{Semantic Version utility class for parsing, storing, and comparing versions. See: http://semver.org}
  s.license       = 'MIT'

  s.files         = Dir['lib/**/*.rb', 'lib/semantic.rb', 'LICENSE', 'README.md']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "rake",    "~> 10.1"
  s.add_development_dependency "rspec",   "~> 2.14"
end
