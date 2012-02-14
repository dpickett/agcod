require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new('test') do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task :default => :test

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
    test.rcov_opts << "-x /Gems/"
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

require File.join(File.dirname(__FILE__), "lib", "agcod", "tasks")

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  require 'agcod/version'

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "agcod #{ Agcod::VERSION }"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

