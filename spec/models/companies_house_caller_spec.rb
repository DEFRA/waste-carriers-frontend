require 'spec_helper'

describe CompaniesHouseCaller do
  describe '#url' do
    context '8 characters in total with whitespace leading whitespace' do
      subject { CompaniesHouseCaller.new ' 2050399' }
      it 'should strip leading whitespace' do
        expect(subject.url).to eq('https://api.companieshouse.gov.uk/company/02050399')
      end
    end

    context '8 characters in total with whitespace trailing whitespace' do
      subject { CompaniesHouseCaller.new '2050399 ' }
      it 'should strip trailing whitespace' do
        expect(subject.url).to eq('https://api.companieshouse.gov.uk/company/02050399')
      end
    end

    context '8 characters' do
      subject { CompaniesHouseCaller.new '02050399' }
      it 'should work with 8 characters' do
        expect(subject.url).to eq('https://api.companieshouse.gov.uk/company/02050399')
      end
    end

    context 'fewer than 8 characters' do
      subject { CompaniesHouseCaller.new '2050399' }
      it 'should prepend zeroes when fewer than 8 characters' do
        expect(subject.url).to eq('https://api.companieshouse.gov.uk/company/02050399')
      end
    end

    context 'lowercase prefix' do
      subject { CompaniesHouseCaller.new 'sc002180' }
      it 'should convert lowercase prefixes to uppercase' do
        expect(subject.url).to eq('https://api.companieshouse.gov.uk/company/SC002180')
      end
    end
  end

  describe '#status' do
    context 'active (PLC, England/Wales, 8 digits)' do
      subject { CompaniesHouseCaller.new '02050399' }

      it 'is active', :vcr do
        subject.status.should == :active
      end
    end

    context 'another active company (PLC, England/Wales, 6 digits with leading zeros omitted)' do
      subject { CompaniesHouseCaller.new '445790' }

      it 'is active', :vcr do
        subject.status.should == :active
      end
    end

    context 'active (LLP, England/Wales)' do
      subject { CompaniesHouseCaller.new 'OC379171' }

      it 'is active', :vcr do
        subject.status.should == :active
      end
    end

    context 'active (PLC, Scotland)' do
      subject { CompaniesHouseCaller.new 'SC028747' }

      it 'is active', :vcr do
        subject.status.should == :active
      end
    end

    context 'active (LLP, Scotland)' do
      subject { CompaniesHouseCaller.new 'SO302113' }

      it 'is active', :vcr do
        subject.status.should == :active
      end
    end

    context 'active (PLC, Northern Ireland)' do
      subject { CompaniesHouseCaller.new 'NI063992' }

      it 'is active', :vcr do
        subject.status.should == :active
      end
    end

    context 'active (LLP, Northern Ireland)' do
      subject { CompaniesHouseCaller.new 'NC000059' }

      it 'is active', :vcr do
        subject.status.should == :active
      end
    end

    context 'active (Industrial and Provident Company, 6 digits)' do
      subject { CompaniesHouseCaller.new 'IP031977' }

      it 'is active', :vcr do
        subject.status.should == :active
      end
    end

    context 'active (Industrial and Provident Company, 5 digits with trailing R)' do
      subject { CompaniesHouseCaller.new 'IP27406R' }

      it 'is active', :vcr do
        subject.status.should == :active
      end
    end

    # TODO: Insert a test to cover behaviour for companies that have "Active -
    # Proposal to Strike off" status.

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
