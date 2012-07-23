require 'rake/clean'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

CLOBBER.include 'pkg'
CLEAN.include 'pkg/*.gem'

task :distclean => [:clean, :clobber]

desc "Run all specs"
RSpec::Core::RakeTask.new
task :default => :spec

