require 'spec_helper'

describe CompaniesHouseCaller do
  describe 'call' do
    subject { CompaniesHouseCaller.new '02050399' }

    its(:url) { should == 'http://data.companieshouse.gov.uk/doc/company/02050399.json' }
  end
end