require "bundler/gem_tasks"
require "rspec/core/rake_task"

Dir.glob('tasks/**/*.rake').each(&method(:import))
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
