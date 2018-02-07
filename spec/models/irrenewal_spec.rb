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

  describe "#already_renewed?" do
    context "when the IR reg. has already been used to renew a registration" do
      subject(:ir_renewal) { build(:irrenewal, :company, :already_renewed) }
      it "returns true" do
        VCR.use_cassette("irrenewal/already_renewed_ir_registration") do
          expect(ir_renewal.already_renewed?).to eq(true)
        end
      end
    end

    context "when the IR reg. has not been renewed" do
      subject(:ir_renewal) { build(:irrenewal, :company) }
      it "returns false" do
        VCR.use_cassette("irrenewal/renewable_ir_registration") do
          expect(ir_renewal.already_renewed?).to eq(false)
        end
      end
    end

    context "when the IR reg. is being used to renew another registration (PENDING)" do
      subject(:ir_renewal) { build(:irrenewal, :company, :being_renewed) }
      it "returns true" do
        VCR.use_cassette("irrenewal/being_renewed_ir_registration") do
          expect(ir_renewal.already_renewed?).to eq(false)
        end
      end
    end

    context "when the waste carriers service Java API is down" do
      subject(:ir_renewal) { build(:irrenewal, :company) }
      it "returns false" do
        # Though expected, it appears a VCR cassette is not needed in this
        # situation
        expect(ir_renewal.already_renewed?).to eq(false)
      end
    end

    context "when the waste carriers service Java API returns an error" do
      subject(:ir_renewal) { build(:irrenewal, :company) }
      it "returns false" do
        VCR.use_cassette("irrenewal/services_returns_error") do
          expect(ir_renewal.already_renewed?).to eq(false)
        end
      end
    end
  end
end
