require 'simplecov-json'
require 'simplecov-rcov'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
  SimpleCov::Formatter::RcovFormatter
]

SimpleCov.start 'rails' do
 merge_timeout 1200 # 20 minutes
 use_merging true
end
