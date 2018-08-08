#Rake task for ci_reporter, with cucumber

unless Rails.env.production?
  require 'ci/reporter/rake/rspec'
  task :spec => 'ci:setup:rspec'

  require 'ci/reporter/rake/cucumber'
end
