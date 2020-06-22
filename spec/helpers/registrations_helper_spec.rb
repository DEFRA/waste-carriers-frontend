require 'spec_helper'

describe RegistrationsHelper do
  describe '#one_full_message_per_invalid_attribute' do
    context 'multiple errors on base' do
      before do
        @registration = Registration.ctor
        @registration.errors[:base] << 'Error 1' << 'Error 2'
      end

      it 'should have both base errors' do
        expect(helper.one_full_message_per_invalid_attribute(@registration)).to eq(['Error 1', 'Error 2'])
      end
    end

    context 'multiple errors on one attibute' do
      before do
        @registration = Registration.ctor
        @registration.errors[:first_name] << 'too short' << 'too common'
      end

      it 'should have first error' do
        expect(helper.one_full_message_per_invalid_attribute(@registration)).to eq(['First name too short'])
      end
    end

    context 'multiple errors on two attributes and base' do
      before do
        @registration = Registration.ctor
        @registration.errors[:first_name] << 'too short' << 'too common'
        @registration.errors[:last_name] << 'too posh' << 'too weird'
        @registration.errors[:base] << 'Error 1' << 'Error 2'
      end

      it 'should have both base errors' do
        expect(helper.one_full_message_per_invalid_attribute(@registration)).to eq(['First name too short', 'Last name too posh', 'Error 1', 'Error 2'])
      end
    end
  end

  describe '#valid_registration_format?' do
    context 'when passed a digital style upper tier registration number' do
      it 'returns true' do
        expect(helper.valid_registration_format?('CBDU215437')).to eq(true)
      end
    end

    context 'when passed a digital style lower tier registration number' do
      it 'returns true' do
        expect(helper.valid_registration_format?('CBDL215437')).to eq(true)
      end
    end

    context 'when passed a digital style registration number with leading and trailing whitespace' do
      it 'returns true' do
        expect(helper.valid_registration_format?('  CBDU215437   ')).to eq(true)
      end
    end

    context 'when passed a digital style registration number with lowercase characters' do
      it 'returns true' do
        expect(helper.valid_registration_format?('cbdu215437')).to eq(true)
      end
    end

    context 'when passed an IR style registration number' do
      it 'returns false' do
        expect(helper.valid_registration_format?('CB/AF7003CS/A001')).to eq(false)
      end
    end

    context 'when passed nonsense' do
      it 'returns false' do
        expect(helper.valid_registration_format?('green eggs and ham')).to eq(false)
      end
    end

    context 'when passed nothing' do
      it 'errors' do
        expect { helper.valid_registration_format?(nil) }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#valid_ir_format?' do
    context 'when passed a digital style upper tier registration number' do
      it 'returns false' do
        expect(helper.valid_ir_format?('CBDU215437')).to eq(false)
      end
    end

    context 'when passed a digital style lower tier registration number' do
      it 'returns false' do
        expect(helper.valid_ir_format?('CBDL215437')).to eq(false)
      end
    end

    context 'when passed a 16 character IR style registration number' do
      it 'returns true' do
        expect(helper.valid_ir_format?('CB/AF7003CS/A001')).to eq(true)
      end
    end

    context 'when passed a 15 character IR style registration number' do
      it 'returns true' do
        expect(helper.valid_ir_format?('CB/AE888XX/A001')).to eq(true)
      end
    end

    context 'when passed an IR style registration number with leading and trailing whitespace' do
      it 'returns true' do
        expect(helper.valid_ir_format?('  CB/AF7003CS/A001   ')).to eq(true)
      end
    end

    context 'when passed an IR style registration number with lowercase characters' do
      it 'returns true' do
        expect(helper.valid_ir_format?('cb/af7003cs/a001')).to eq(true)
      end
    end

    context 'when passed nonsense' do
      it 'returns false' do
        expect(helper.valid_ir_format?('green eggs and ham')).to eq(false)
      end
    end

    context 'when passed nothing' do
      it 'returns false' do
        expect(helper.valid_ir_format?(nil)).to eq(false)
      end
    end
  end

  describe "#back_office_details_url" do
    it "returns the correct URL" do
      registration = build(:registration, regIdentifier: "CBDU99999")
      url = "http://localhost:8001/bo/registrations/CBDU99999"
      expect(helper.back_office_details_url(registration)).to eq(url)
    end
  end

  describe "#back_office_renewals_url" do
    it "returns the correct URL" do
      registration = build(:registration, regIdentifier: "CBDU99999")
      # url = "http://localhost:8001/bo/ad-privacy-policy/CBDU99999"
      url = "http://localhost:8001/bo/ad-privacy-policy?reg_identifier=CBDU99999"
      expect(helper.back_office_renewals_url(registration)).to eq(url)
    end
  end

  describe "#back_office_transfer_url" do
    it "returns the correct URL" do
      registration = build(:registration, regIdentifier: "CBDU99999")
      url = "http://localhost:8001/bo/registrations/CBDU99999/transfer"
      expect(helper.back_office_transfer_url(registration)).to eq(url)
    end
  end

  describe "#back_office_edit_url" do
    it "returns the correct URL" do
      registration = build(:registration, regIdentifier: "CBDU99999")
      url = "http://localhost:8001/bo/CBDU99999/edit"
      expect(helper.back_office_edit_url(registration)).to eq(url)
    end
  end

  describe "#back_office_order_copy_cards_url" do
    it "returns the correct URL" do
      registration = build(:registration, regIdentifier: "CBDU99999")
      url = "http://localhost:8001/bo/CBDU99999/order-copy-cards"
      expect(helper.back_office_order_copy_cards_url(registration)).to eq(url)
    end
  end

  describe "#back_office_payment_details_url" do
    it "returns the correct URL" do
      registration = build(:registration, uuid: "abcde12345")
      url = "http://localhost:8001/bo/resources/abcde12345/finance-details"
      expect(helper.back_office_payment_details_url(registration)).to eq(url)
    end
  end

  describe "#back_office_view_certificate_url" do
    it "returns the correct URL" do
      registration = build(:registration, regIdentifier: "CBDU99999")
      url = "http://localhost:8001/bo/registrations/CBDU99999/certificate"
      expect(helper.back_office_view_certificate_url(registration)).to eq(url)
    end
  end
end
