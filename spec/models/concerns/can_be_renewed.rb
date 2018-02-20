require 'spec_helper'

shared_examples_for "can_be_renewed" do
  describe "#can_renew?" do
    subject do
      registration = described_class.ctor
      registration.tier = "UPPER"
      registration.expires_on = date_to_utc_milliseconds(Date.tomorrow)
      registration.metaData.first.update(status: 'ACTIVE')
      registration
    end

    context "when the registration is eligible for renewal" do
      it "can be renewed" do
        expect(subject.can_renew?).to eq(true)
      end
    end

    context "when the registration is lower tier" do
      it "cannot be renewed" do
        subject.tier = "LOWER"
        expect(subject.can_renew?).to eq(false)
      end
    end

    context "when the registration is expired" do
      it "cannot be renewed" do
        subject.expires_on = date_to_utc_milliseconds(Date.today)
        expect(subject.can_renew?).to eq(false)
      end
    end

    context "when the registration is not ACTIVE" do
      it "cannot be renewed" do
        subject.metaData.first.update(status: 'REVOKED')
        expect(subject.can_renew?).to eq(false)
      end
    end

    context "when the registration expires outside the renewal window" do
      before do
        Rails.configuration.stub(:registration_renewal_window).and_return(3.months)
      end

      it "cannot be renewed" do
        expiry_date = (3.months.from_now + 2.day).to_date
        subject.expires_on = date_to_utc_milliseconds(expiry_date)
        expect(subject.can_renew?).to eq(false)
      end
    end
  end

  describe "#expired?" do
    subject do
      registration = described_class.ctor
      registration.tier = "UPPER"
      registration.expires_on = date_to_utc_milliseconds(Date.tomorrow)
      registration.metaData.first.update(status: 'ACTIVE')
      registration
    end

    context "when the registration is ACTIVE and not expired" do
      it "returns false" do
        expect(subject.expired?).to eq(false)
      end
    end

    context "when the registration's status is EXPIRED" do
      it "returns true" do
        subject.metaData.first.update(status: 'EXPIRED')
        expect(subject.expired?).to eq(true)
      end
    end

    context "when the registration expired yesterday" do
      it "returns true" do
        subject.expires_on = date_to_utc_milliseconds(Date.yesterday)
        expect(subject.expired?).to eq(true)
      end
    end

    context "when the registration is lower tier" do
      it "returns true" do
        subject.tier = "LOWER"
        expect(subject.expired?).to eq(false)
      end
    end
  end

  describe "#renewals_url" do
    before do
      Rails.configuration.stub(:renewals_service_url).and_return("http://localhost:3000/renew/")
    end

    subject do
      registration = described_class.ctor
      registration.regIdentifier = "CBDU1"
      registration
    end

    it "returns the configured url with the registration number appended to the end" do
      subject.tier = "LOWER"
      expect(subject.renewals_url).to eq("http://localhost:3000/renew/CBDU1")
    end
  end
end
