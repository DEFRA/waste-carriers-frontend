# if ENV['GENERATE_REPORTS'] == 'true'
require 'ci/reporter/rake/rspec'
task :spec => 'ci:setup:rspec'
# end

require 'ci/reporter/rake/cucumber'
