require 'spec_helper'

describe CompaniesHouseCaller do
  describe '#url' do
    context '8 characters' do
      subject { CompaniesHouseCaller.new '02050399' }

      its(:url) { should == 'http://data.companieshouse.gov.uk/doc/company/02050399.json' }
    end

    context 'fewer than 8 characters' do
      subject { CompaniesHouseCaller.new '2050399' }

      its(:url) { should == 'http://data.companieshouse.gov.uk/doc/company/02050399.json' }
    end
  end

  describe '#active?' do
    context 'active' do
      subject { CompaniesHouseCaller.new '02050399' }

      it { should be_active }
    end

    context 'not active' do
      subject { CompaniesHouseCaller.new '05868270' }

      it { should_not be_active }
    end

    context 'not found' do
      subject { CompaniesHouseCaller.new '99999999' }

      it { should_not be_active }
    end
  end

  describe 'external service unavailable' do
    it "it should indicate this"
  end
end