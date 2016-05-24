require 'spec_helper'

describe RegistrationOrder do

  let(:new_registration) { build(:registration, :creating) }
  let(:ir_renewal_registration) { build(:registration, :ir_renewal) }
  let(:ir_renewal_cd_registration) { build(:registration, :ir_renewal, registrationType: 'carrier_dealer') }
  let(:ir_renewal_partnership_registration) { build(:registration, :ir_renewal, businessType: 'partnership') }

  describe "#order_type" do

    context 'when registration is a new registration' do
      let(:registration_order) { RegistrationOrder.new(new_registration) }
      it { expect(registration_order.order_types).to eq([:new]) }
    end

    context 'when registration is an IR renewal' do
      let(:registration_order) do
        RegistrationOrder.any_instance.stub(:ir_renewal).and_return(ir_renewal_registration)
        RegistrationOrder.new(ir_renewal_registration)
      end
      it { expect(registration_order.order_types).to eq([:renew]) }
    end

    context 'when registration is an IR renewal and reg type changed' do
      let(:registration_order) do
        RegistrationOrder.any_instance.stub(:ir_renewal).and_return(ir_renewal_cd_registration)
        RegistrationOrder.new(ir_renewal_registration)
      end
      it { expect(registration_order.order_types).to eq([:change_reg_type, :renew]) }
    end

    context 'when registration is an IR renewal and business type changed' do
      let(:registration_order) do
        RegistrationOrder.any_instance.stub(:ir_renewal).and_return(ir_renewal_partnership_registration)
        RegistrationOrder.new(ir_renewal_registration)
      end
      it { expect(registration_order.order_types).to eq([:change_caused_new]) }
    end

  end

  describe "#is_reg_type_change?" do

    context "when carrier type has not been changed" do
      it "is false" do
        original_ir_renewal_registration = ir_renewal_registration
        RegistrationOrder.any_instance.stub(:ir_renewal).and_return(original_ir_renewal_registration)
        registration_order = RegistrationOrder.new(ir_renewal_registration)
        expect(registration_order.is_reg_type_change?).to be_falsey
      end
    end

    context "when carrier type has been changed" do
      it "is true" do
        original_ir_renewal_registration = build(:registration, :ir_renewal, registrationType: 'carrier_dealer' )
        RegistrationOrder.any_instance.stub(:ir_renewal).and_return(original_ir_renewal_registration)
        registration_order = RegistrationOrder.new(ir_renewal_registration)
        expect(registration_order.is_reg_type_change?).to be_truthy
      end
    end

  end

  describe "#is_legal_entity_change?" do
    let(:original_registration) { build(:registration, :editing, :partnership) }
    let(:new_registration) { build(:registration, :editing, :partnership) }

    context "when partnership company number has been changed" do
      it "is false" do
        original_registration.company_no = '123456'
        new_registration.company_no = '999999'
        RegistrationOrder.any_instance.stub(:original_registration).and_return(original_registration)
        registration_order = RegistrationOrder.new(new_registration)
        expect(registration_order.is_legal_entity_change?).to be_falsey
      end
    end

    context "when no key person has been added to a partnership" do
      it "is false" do
        RegistrationOrder.any_instance.stub(:original_registration).and_return(original_registration)
        registration_order = RegistrationOrder.new(new_registration)
        expect(registration_order.is_legal_entity_change?).to be_falsey
      end
    end

    context "when a key person has been removed from a partnership" do
      it "is false" do
        original_registration.key_people.add(build(:key_person))
        RegistrationOrder.any_instance.stub(:original_registration).and_return(original_registration)
        registration_order = RegistrationOrder.new(new_registration)
        expect(registration_order.is_legal_entity_change?).to be_falsey
      end
    end

    context "when a key person has been added to a partnership" do
      it "is true" do
        new_registration.key_people.add(build(:key_person))
        RegistrationOrder.any_instance.stub(:original_registration).and_return(original_registration)
        registration_order = RegistrationOrder.new(new_registration)
        expect(registration_order.is_legal_entity_change?).to be_truthy
      end
    end

    context "when limited company number has been changed" do
      let(:original_registration) { build(:registration, :editing) }
      let(:new_registration) { build(:registration, :editing) }
      it "is true" do
        original_registration.company_no = '123456'
        new_registration.company_no = '999999'
        RegistrationOrder.any_instance.stub(:original_registration).and_return(original_registration)
        registration_order = RegistrationOrder.new(new_registration)
        expect(registration_order.is_legal_entity_change?).to be_truthy
      end
    end

  end


end
