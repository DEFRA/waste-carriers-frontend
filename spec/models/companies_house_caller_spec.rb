require 'spec_helper'

describe CompaniesHouseCaller do
  describe 'url' do
    context '8 characters' do
      subject { CompaniesHouseCaller.new '02050399' }

      its(:url) { should == 'http://data.companieshouse.gov.uk/doc/company/02050399.json' }
    end

    context 'fewer than 8 characters' do
      subject { CompaniesHouseCaller.new '2050399' }

      its(:url) { should == 'http://data.companieshouse.gov.uk/doc/company/02050399.json' }
    end
  end
end