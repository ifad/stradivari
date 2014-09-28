require "rake/clean"
require "rake/testtask"
require "bundler/gem_tasks"

task :default => :test

CLEAN.replace %w(pkg doc coverage .yardoc test/haml vendor)

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  files = Dir["test/*_test.rb"]
  t.test_files = files
  t.warning = false
  t.verbose = false
end
