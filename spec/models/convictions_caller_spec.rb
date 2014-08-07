require 'spec_helper'

describe ConvictionsCaller do

  describe '.initialize' do
    context 'params for individual' do
      expect { ConvictionsCaller.new(name: 'Barry Butler', dateOfBirth: '1970-01-01') }.not_to raise_error
    end

    context 'params for company' do
      expect { ConvictionsCaller.new(name: 'Acme Inc.', companyNumber: '99999999') }.not_to raise_error
    end

    context 'mix of params for company and individual' do
      expect { ConvictionsCaller.new(name: 'Acme Inc.', companyNumber: '99999999', dateOfBirth: '1970-01-01') }.not_to raise_error
    end

    context 'invalid params' do
      expect { ConvictionsCaller.new(name: 'Acme Inc.', companyNo: '99999999') }.to raise_error
    end
  end

end