require 'spec_helper'

describe Irrenewal do
  context "Renewing a registration" do
    subject(:ir_renewal) { build(:irrenewal, :company) }

    it "Just works" do
      expect(ir_renewal.applicantType).to eq('Company')
    end
  end
end
