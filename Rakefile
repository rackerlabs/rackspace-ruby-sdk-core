require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Start a terminal with this gem preloaded."
task :console do
  exec "irb -r rackspace_ruby_sdk_core -I ./lib"
end
