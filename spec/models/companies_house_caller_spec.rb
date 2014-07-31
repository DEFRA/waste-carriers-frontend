require 'spec_helper'

describe CompaniesHouseCaller do
  describe '#url' do
    context '8 characters in total with whitespace leading whitespace' do
      subject { CompaniesHouseCaller.new ' 2050399' }

      its(:url) { should == 'http://data.companieshouse.gov.uk/doc/company/02050399.json' }
    end

    context '8 characters in total with whitespace trailing whitespace' do
      subject { CompaniesHouseCaller.new '2050399 ' }

      its(:url) { should == 'http://data.companieshouse.gov.uk/doc/company/02050399.json' }
    end

    context '8 characters' do
      subject { CompaniesHouseCaller.new '02050399' }

      its(:url) { should == 'http://data.companieshouse.gov.uk/doc/company/02050399.json' }
    end

    context 'fewer than 8 characters' do
      subject { CompaniesHouseCaller.new '2050399' }

      its(:url) { should == 'http://data.companieshouse.gov.uk/doc/company/02050399.json' }
    end

    context 'lowercase prefix' do
      subject { CompaniesHouseCaller.new 'sc002180' }

      its(:url) { should == 'http://data.companieshouse.gov.uk/doc/company/SC002180.json' }
    end
  end

  describe '#status' do
    context 'active' do
      subject { CompaniesHouseCaller.new '02050399' }

      it 'is active', :vcr do
        subject.status.should == :active
      end
    end

    context 'another active company' do
      subject { CompaniesHouseCaller.new '7540106' }

      it 'is active', :vcr do
        subject.status.should == :active
      end
    end

    context 'not active' do
      subject { CompaniesHouseCaller.new '05868270' }

      it 'is not active', :vcr do
        subject.status.should == :inactive
      end
    end

    context 'not found' do
      subject { CompaniesHouseCaller.new '99999999' }

      it 'is not found', :vcr do
        subject.status.should == :not_found
      end
    end
  end

  describe 'external service unavailable' do
    context 'timeout' do
      before { stub_request(:any, 'data.companieshouse.gov.uk').to_timeout }

      subject { CompaniesHouseCaller.new '02050399' }

      its(:status) { should == :error_calling_service }
    end

    context 'server error' do
      before { stub_request(:any, 'data.companieshouse.gov.uk').to_raise }

      subject { CompaniesHouseCaller.new '02050399' }

      its(:status) { should == :error_calling_service }
    end
  end
end