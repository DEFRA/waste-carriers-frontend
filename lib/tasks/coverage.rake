desc "Run RSpec and Cucumber with code coverage check"
task :coverage do
  ENV['COVERAGE'] = 'true'
  sh "rspec"
  sh "cucumber"
end
