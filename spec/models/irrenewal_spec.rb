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

  context "Renewing a registration" do
    subject(:ir_renewal) { build(:irrenewal, :company) }

    it "Just works" do
      expect(ir_renewal.applicantType).to eq('Company')
    end
  end
end
