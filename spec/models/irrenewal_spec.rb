require 'spec_helper'

describe Irrenewal do

  describe "#already_renewed?" do
    context "when the IR reg. has already been used to renew a registration" do
      subject(:ir_renewal) { build(:irrenewal, :company, :already_renewed) }
      it "returns true" do
        VCR.use_cassette("irrenewal/already_renewed_ir_registration", record: :none) do
          expect(ir_renewal.already_renewed?).to eq(true)
        end
      end
    end

    context "when the IR reg. has not been renewed" do
      subject(:ir_renewal) { build(:irrenewal, :company) }
      it "returns false" do
        VCR.use_cassette("irrenewal/renewable_ir_registration", record: :none) do
          expect(ir_renewal.already_renewed?).to eq(false)
        end
      end
    end

    context "when the IR reg. is being used to renew another registration (PENDING)" do
      subject(:ir_renewal) { build(:irrenewal, :company, :being_renewed) }
      it "returns true" do
        VCR.use_cassette("irrenewal/being_renewed_ir_registration", record: :none) do
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
        VCR.use_cassette("irrenewal/services_returns_error", record: :none) do
          expect(ir_renewal.already_renewed?).to eq(false)
        end
      end
    end
  end
end
