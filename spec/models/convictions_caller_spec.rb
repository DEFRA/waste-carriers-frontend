require 'spec_helper'

describe ConvictionsCaller do

  describe '.initialize' do
    context 'params for individual' do
      it 'does not error' do
        expect { ConvictionsCaller.new(name: 'Barry Butler', dateOfBirth: '1970-01-01') }.not_to raise_error
      end
    end

    context 'params for company' do
      it 'does not error' do
        expect { ConvictionsCaller.new(name: 'Acme Inc.', companyNumber: '99999999') }.not_to raise_error
      end
    end

    context 'mix of params for company and individual' do
      it 'does not error' do
        expect { ConvictionsCaller.new(name: 'Acme Inc.', companyNumber: '99999999', dateOfBirth: '1970-01-01') }.not_to raise_error
      end
    end

    context 'invalid params' do
      it 'errors' do
        expect { ConvictionsCaller.new(name: 'Acme Inc.', companyNo: '99999999') }.to raise_error
      end
    end

    context 'empty params' do
      it 'errors' do
        expect { ConvictionsCaller.new({}) }.to raise_error
      end
    end
  end

  describe '#check_convictions' do
    describe 'service unavailable' do
      context 'timeout' do
        before { stub_request(:any, 'localhost:9290').to_timeout }

        subject { ConvictionsCaller.new name: 'Acme Inc.', companyNumber: '99999999' }

        its(:check_convictions) { should include(:system => 'error') }
      end

      context 'server error' do
        before { stub_request(:any, 'localhost:9290').to_raise }

        subject { ConvictionsCaller.new name: 'Acme Inc.', companyNumber: '99999999' }

        its(:check_convictions) { should include(:system => 'error') }
      end
    end
  end
end
