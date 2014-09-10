require 'spec_helper'

describe ConvictionSearchResult do

  describe '.search_convictions' do

    context 'params for individual' do
      it 'does not error' do
        expect { ConvictionSearchResult.search_convictions(name: 'Barry Butler', dateOfBirth: '1970-01-01') }.not_to raise_error
      end
    end

    context 'params for company' do
      it 'does not error' do
        expect { ConvictionSearchResult.search_convictions(name: 'Acme Inc.', companyNumber: '99999999') }.not_to raise_error
      end
    end

    context 'mix of params for company and individual' do
      it 'does not error' do
        expect { ConvictionSearchResult.search_convictions(name: 'Acme Inc.', companyNumber: '99999999', dateOfBirth: '1970-01-01') }.not_to raise_error
      end
    end

    context 'invalid params' do
      it 'errors' do
        expect { ConvictionSearchResult.search_convictions(name: 'Acme Inc.', companyNo: '99999999') }.to raise_error
      end
    end

    context 'empty params' do
      it 'errors' do
        expect { ConvictionSearchResult.search_convictions({}) }.to raise_error
      end
    end

    describe 'service unavailable' do
      context 'timeout' do
        before { stub_request(:any, 'localhost:9290').to_timeout }

        it 'should return a result flagged as an error' do
          ConvictionSearchResult.search_convictions(name: 'Acme Inc.', companyNumber: '99999999').should include(:system => 'error')
        end

      end

      context 'server error' do
        before { stub_request(:any, 'localhost:9290').to_raise }

        it 'should return a result flagged as an error' do
          ConvictionSearchResult.search_convictions(name: 'Acme Inc.', companyNumber: '99999999').should include(:system => 'error')
          
      end
    end
  end
end
