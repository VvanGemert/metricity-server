require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/test_**.rb']
  t.verbose = true
end

desc "Run tests"
task :default => :test