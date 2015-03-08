require 'bundler/gem_tasks'
require 'rake/testtask'
require 'coveralls/rake/task'

Coveralls::RakeTask.new

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

task :default => [:test]
