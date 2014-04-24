require 'ci/reporter/rake/rspec'
task :spec => 'ci:setup:rspec'

require 'ci/reporter/rake/cucumber'
