# -*- encoding: utf-8 -*-
require 'rake'

$:.push File.expand_path("../lib", __FILE__)
require 'semantic'

Gem::Specification.new do |s|
  s.name          = "semantic"
  s.version       = Semantic::GEM_VERSION
  s.authors       = ["Josh Lindsey"]
  s.email         = ["josh@core-apps.com"]
  s.homepage      = "https://github.com/jlindsey/semantic"
  s.summary       = %q{Semantic Version utility class}
  s.description   = %q{Semantic Version utility class for parsing, storing, and comparing versions. See: http://semver.org}
  s.license       = 'MIT'

  s.files         = FileList['lib/**/*.rb', 'LICENSE', 'README.md']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "rake",    "~> 0.9.2.2"
  s.add_development_dependency "rspec",   "~> 2.11.0"
end

