require 'bundler/setup'
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

begin
  require 'appraisal/task'
  Appraisal::Task.new
rescue LoadError
  # appraisal is optional
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  # yard is optional
end

task default: :spec
