require 'spec_helper'

describe WorldpayHelper do
  describe '#worldpay_address' do
    let(:address) do
      address = build(:address)
      address.houseNumber = '29'
      address.addressLine1 = 'Acacia Road'
      address.addressLine2 = ''
      address.addressLine3 = ''
      address.addressLine4 = ''
      address.townCity = 'Nuttytown'
      address.postcode = 'BN4 1MN'
      address.country = 'United Kingdom'
      address
    end

    context "when passed an address where the house number isn't blank" do
      it 'returns a hash containing valid Worldpay keys and values' do
        expect(helper.worldpay_address(address)).to eq(
          line_1: '29',
          line_2: 'Acacia Road',
          town_city: 'Nuttytown',
          postcode: 'BN4 1MN',
          country_code: 'GB'
        )
      end
    end

    context 'when passed an address where the house number is blank' do
      it 'returns a hash containing valid Worldpay keys and values' do
        address.houseNumber = nil
        expect(helper.worldpay_address(address)).to eq(
          line_1: 'Acacia Road',
          line_2: '',
          town_city: 'Nuttytown',
          postcode: 'BN4 1MN',
          country_code: 'GB'
        )
      end
    end

    context 'when passed an address without a country' do
      it "defaults the country code to 'GB' in the returned hash" do
        address.country = nil
        expect(helper.worldpay_address(address)[:country_code]).to eq('GB')
      end
    end

    context 'when passed an address with a recognised country' do
      it 'sets the country code correctly in the returned hash' do
        address.country = 'Slovakia'
        expect(helper.worldpay_address(address)[:country_code]).to eq('SK')
      end
    end

    context 'when passed an address with a unrecognised country' do
      it "defaults the country code to 'GB' in the returned hash" do
        address.country = 'Wakanda'
        expect(helper.worldpay_address(address)[:country_code]).to eq('GB')
      end
    end
  end
end
