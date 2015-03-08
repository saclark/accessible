require 'bundler/gem_tasks'
require 'coveralls/rake/task'
require 'rake/testtask'

Coveralls::RakeTask.new

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

task :default => [:test]
