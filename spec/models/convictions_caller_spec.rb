require 'spec_helper'

describe ConvictionsCaller do

  describe '.initialize' do
    context 'params for individual' do
      it 'does not raise error' do
        expect { ConvictionsCaller.new(name: 'Barry Butler', dateOfBirth: '1970-01-01') }.not_to raise_error
      end
    end

    context 'params for company' do
      it 'does not raise error' do
        expect { ConvictionsCaller.new(name: 'Acme Inc.', companyNumber: '99999999') }.not_to raise_error
      end
    end

    context 'mix of params for company and individual' do
      it 'does not raise error' do
        expect { ConvictionsCaller.new(name: 'Acme Inc.', companyNumber: '99999999', dateOfBirth: '1970-01-01') }.not_to raise_error
      end
    end

    context 'invalid params' do
      it 'does raise error' do
        expect { ConvictionsCaller.new(name: 'Acme Inc.', companyNo: '99999999') }.to raise_error
      end
    end
  end

end