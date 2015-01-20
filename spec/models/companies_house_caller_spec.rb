require 'spec_helper'

describe CompaniesHouseCaller do
  describe '#url' do
    context '8 characters in total with whitespace leading whitespace' do
      subject { CompaniesHouseCaller.new ' 2050399' }
      it 'should strip leading whitespace' do
        expect(subject.url).to eq('http://data.companieshouse.gov.uk/doc/company/02050399.json')
      end
    end

    context '8 characters in total with whitespace trailing whitespace' do
      subject { CompaniesHouseCaller.new '2050399 ' }
      it 'should strip trailing whitespace' do
        expect(subject.url).to eq('http://data.companieshouse.gov.uk/doc/company/02050399.json')
      end
    end

    context '8 characters' do
      subject { CompaniesHouseCaller.new '02050399' }
      it 'should work with 8 characters' do
        expect(subject.url).to eq('http://data.companieshouse.gov.uk/doc/company/02050399.json')
      end
    end

    context 'fewer than 8 characters' do
      subject { CompaniesHouseCaller.new '2050399' }
      it 'should prepend zeroes when fewer than 8 characters' do
        expect(subject.url).to eq('http://data.companieshouse.gov.uk/doc/company/02050399.json')
      end
    end

    context 'lowercase prefix' do
      subject { CompaniesHouseCaller.new 'sc002180' }
      it 'should convert lowercase prefixes to uppercase' do
        expect(subject.url).to eq('http://data.companieshouse.gov.uk/doc/company/SC002180.json')
      end
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

      it 'should error upon timeout' do
        expect(subject.status).to eq(:error_calling_service)
      end
    end

    context 'server error' do
      before { stub_request(:any, 'data.companieshouse.gov.uk').to_raise }

      subject { CompaniesHouseCaller.new '02050399' }

      it 'should error upon server error' do
        expect(subject.status).to eq(:error_calling_service)
      end
    end
  end
end
