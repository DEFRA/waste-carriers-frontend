require 'spec_helper'

describe Irrenewal do
  describe "#expired?" do
    context "when the IR registration has expired" do
      subject(:ir_renewal) { build(:irrenewal, :company, :expired) }
      it "returns true" do
        expect(ir_renewal.expired?).to eq(true)
      end
    end

    context "when the IR registration is not expired" do
      subject(:ir_renewal) { build(:irrenewal, :company) }
      it "returns false" do
        expect(ir_renewal.expired?).to eq(false)
      end
    end
  end

  describe "#in_renewal_window?" do
    context "when the IR registration has expired" do
      subject(:ir_renewal) { build(:irrenewal, :company, :expired) }
      it "returns false" do
        expect(ir_renewal.in_renewal_window?).to eq(false)
      end
    end

    context "when the IR reg. expires within the renewal window" do
      subject(:ir_renewal) { build(:irrenewal, :company) }
      it "returns true" do
        expect(ir_renewal.in_renewal_window?).to eq(true)
      end
    end

    context "when the IR reg. expires after the renewal window" do
      subject(:ir_renewal) { build(:irrenewal, :company, :expires_outside_renewal_window) }
      it "returns false" do
        expect(ir_renewal.in_renewal_window?).to eq(false)
      end
    end
  end
end
