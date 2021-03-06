require "spec_helper"

shared_examples_for "can_be_renewed" do
  let(:registration) do
    registration = described_class.ctor
    registration.regIdentifier = "CBDU1"
    registration.tier = "UPPER"
    registration.metaData.first.update(status: "ACTIVE")
    registration.expires_on = date_to_utc_milliseconds(Date.tomorrow)
    registration
  end

  # can_renew? is essentially a helper method on the model that wraps
  # RenewalHelperService.can_renew? Hence we just have a couple of tests here
  # to ensure the concern is setup and working correctly, but to see all the
  # full behaviour check out spec/services/renewal_helper_service_spec.rb
  describe "#can_renew?" do
    context "when the registration is eligible for renewal" do
      it "can be renewed" do
        expect(registration.can_renew?).to eq(true)
      end
    end

    context "when the registration is not eligible for renewal" do
      it "cannot be renewed" do
        registration.metaData.first.update(status: "REVOKED")
        expect(registration.can_renew?).to eq(false)
      end
    end
  end

  describe "#expired?" do
    context "when the registration is lower tier" do
      it "returns true" do
        registration.tier = "LOWER"
        expect(registration.expired?).to eq(false)
      end
    end

    context "when the registration is 'ACTIVE' and in date" do
      it "returns false" do
        expect(registration.expired?).to eq(false)
      end
    end

    context "when the registration is 'EXPIRED'" do
      it "returns true" do
        registration.metaData.first.update(status: "EXPIRED")
        expect(registration.expired?).to eq(true)
      end
    end

    context "when the 'expires_on' date is today" do
      let(:expired_regisration) do
        registration.expires_on = date_to_utc_milliseconds(Date.today)
        registration
      end

      context "and the registration is 'EXPIRED'" do
        it "returns true" do
          expired_regisration.metaData.first.update(status: "EXPIRED")
          expect(expired_regisration.expired?).to eq(true)
        end
      end

      # Registrations are marked as expired by a job that runs daily at 8pm. It
      # should pick up all registrations due to expire on a given day but in the
      # event it fails to run the status of expired registrations won't get.
      # Hence we have an additional check on the expires_on date as well as the
      # check on the status
      context "and the registration is still 'ACTIVE'" do
        it "still returns true" do
          expect(expired_regisration.expired?).to eq(true)
        end
      end
    end
  end

  describe "#renewals_url" do
    before do
      allow(Rails.configuration).to receive(:front_office_url).and_return("http://localhost:3000/fo")
    end

    it "returns the configured url with the registration number as part of the path" do
      expect(registration.renewals_url).to eq("http://localhost:3000/fo/CBDU1/renew")
    end
  end
end
