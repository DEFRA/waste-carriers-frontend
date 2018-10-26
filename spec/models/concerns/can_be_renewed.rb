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
        expect(subject.can_renew?(true)).to eq(false)
        expect(subject.errors.first[1]).to eq("This is a lower tier registration so never expires. Call our helpline on 03708 506506 if you think this is incorrect.")
      end
    end

    context "when the registration is expired" do
      context "and we are outside the 'grace window'" do
        context "if the status is expired" do
          it "cannot be renewed" do
            subject.metaData.first.update(status: 'EXPIRED')
            expect(subject.can_renew?(true)).to eq(false)
            expect(subject.errors.first[1]).to eq("The registration number you entered has expired")
          end
        end

        context "if the expires_on date is expired" do
          # Registrations are marked as EXPIRED by the waste-carriers-service.
          # We know the job runs at 8pm each day, and has been fixed to ignore the
          # time element, however just to be sure, or in the event the service
          # goes down, the class checks both the status and the expires_on field.
          # Hence we test both contexts here.
          it "cannot be renewed" do
            subject.expires_on = date_to_utc_milliseconds(Date.today)
            expect(subject.can_renew?(true)).to eq(false)
            expect(subject.errors.first[1]).to eq("The registration number you entered has expired")
          end
        end
      end

      context "and we are inside the 'grace window'" do
        context "if the status is expired" do
          it "can be renewed" do
            subject.metaData.first.update(status: 'EXPIRED')
            expect(subject.can_renew?(true)).to eq(true)
          end
        end

        context "if the expires_on date is expired" do
          # Registrations are marked as EXPIRED by the waste-carriers-service.
          # We know the job runs at 8pm each day, and has been fixed to ignore the
          # time element, however just to be sure, or in the event the service
          # goes down, the class checks both the status and the expires_on field.
          # Hence we test both contexts here.
          it "can be renewed" do
            subject.expires_on = date_to_utc_milliseconds(Date.today)
            expect(subject.can_renew?(true)).to eq(true)
          end
        end
      end
    end

    context "when the registration is not ACTIVE" do
      it "cannot be renewed" do
        subject.metaData.first.update(status: 'REVOKED')
        expect(subject.can_renew?(true)).to eq(false)
        expect(subject.errors.first[1]).to eq("This number is not registered. Call our helpline on 03708 506506 if you think this is incorrect.")
      end
    end

    context "when the registration expires outside the renewal window" do
      it "cannot be renewed" do
        expiry_date = (3.months.from_now + 2.day).to_date
        subject.expires_on = date_to_utc_milliseconds(expiry_date)
        renew_from = ExpiryDateService.new(expiry_date).date_can_renew_from
        expect(subject.can_renew?(true)).to eq(false)
        expect(subject.errors.first[1]).to eq("This registration is not eligible for renewal until #{renew_from.to_formatted_s(:day_month_year)}.")
      end
    end

    context "when the registration cannot be renewed and save validations is disabled" do
      it "no validation messages should be added to the registration's error collection" do
        subject.tier = "LOWER"
        expect(subject.can_renew?(false)).to eq(false)
        expect(subject.errors.empty?).to eq(true)
      end
    end

    context "when the registration cannot be renewed and save validations is enabled" do
      it "adds a validation message to the registration's error collection" do
        subject.tier = "LOWER"
        expect(subject.can_renew?(true)).to eq(false)
        expect(subject.errors.empty?).to eq(false)
      end
    end

    context "when the registration cannot be renewed, save validations is enabled and we pass a different error_id" do
      it "adds a validation message to the registration's error collection with the same error id" do
        subject.tier = "LOWER"
        expect(subject.can_renew?(true,:originalRegistrationNumber)).to eq(false)
        expect(subject.errors.first[0]).to eq(:originalRegistrationNumber)
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

  describe "#in_expiry_grace_window?" do
    subject do
      registration = described_class.ctor
      registration.tier = "UPPER"
      registration.metaData.first.update(status: "EXPIRED")
      registration
    end

    context "when the registration is lower tier" do
      it "returns false" do
        subject.tier = "LOWER"
        expect(subject.in_expiry_grace_window?).to eq(false)
      end
    end

    context "when the expires_on date is within the window" do
      it "returns true" do
        subject.expires_on = date_to_utc_milliseconds(Date.today)
        expect(subject.in_expiry_grace_window?).to eq(true)
      end
    end

    context "when the expires_on date is outside the window" do
      it "returns false" do
        subject.expires_on = date_to_utc_milliseconds(Date.today)
        expect(subject.in_expiry_grace_window?).to eq(false)
      end
    end
  end

  describe "#renewals_url" do
    before do
      allow(Rails.configuration).to receive(:renewals_service_url).and_return("http://localhost:3000/renew/")
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

  describe "#back_office_renewals_url" do
    before do
      allow(Rails.configuration).to receive(:back_office_renewals_url).and_return("http://localhost:8001/bo/renew/")
    end

    subject do
      registration = described_class.ctor
      registration.regIdentifier = "CBDU1"
      registration
    end

    it "returns the configured url with the registration number appended to the end" do
      subject.tier = "LOWER"
      expect(subject.back_office_renewals_url).to eq("http://localhost:8001/bo/renew/CBDU1")
    end
  end
end
