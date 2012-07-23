require 'rake/clean'
require 'rake/testtask'
require 'bundler/gem_tasks'

CLOBBER.include 'pkg'
CLEAN.include 'pkg/*.gem'

task :distclean => [:clean, :clobber]

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end
task :default => :test

