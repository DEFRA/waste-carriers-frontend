require "spec_helper"

RSpec.describe RenewalHelperService do
  let(:registration) do
    registration = Registration.ctor
    registration.regIdentifier = "CBDU1"
    registration.tier = "UPPER"
    registration.expires_on = date_to_utc_milliseconds(Date.tomorrow)
    registration.metaData.first.update(status: "ACTIVE")
    registration
  end

  subject { RenewalHelperService.new(registration, true) }

  describe "#initialize" do
    context "when initialized with a registration" do
      it "sets :registration to that registration" do
        expect(subject.registration.regIdentifier).to eq("CBDU1")
      end
    end

    context "when initialized with an unrenewable registration" do
      let(:unrenewable_registration) do
        registration.tier = "LOWER"
        registration
      end

      context "and 'log_reason' set to false" do
        subject { RenewalHelperService.new(unrenewable_registration, false) }

        it "does not add any validation messages to the registration's error collection" do
          expect(subject.can_renew?).to eq(false)
          expect(subject.registration.errors.empty?).to eq(true)
        end
      end

      context "and 'log_reason' set to true" do
        subject { RenewalHelperService.new(unrenewable_registration, true, :originalRegistrationNumber) }

        it "adds a validation message to the registration's error collection" do
          expect(subject.can_renew?).to eq(false)
          expect(subject.registration.errors.empty?).to eq(false)
        end

        context "and 'error_id' is specified" do
          it "adds a validation message to the registration's error collection with the same error id" do
            expect(subject.can_renew?).to eq(false)
            expect(subject.registration.errors.first[0]).to eq(:originalRegistrationNumber)
          end
        end
      end
    end
  end

  describe "#can_renew?" do
    context "when the registration is eligible for renewal" do
      it "can be renewed" do
        expect(subject.can_renew?).to eq(true)
      end
    end

    context "when the registration is lower tier" do
      it "cannot be renewed" do
        subject.registration.tier = "LOWER"

        expect(subject.can_renew?).to eq(false)
        expect(subject.registration.errors.first[1]).to eq("This is a lower tier registration so never expires. Call our helpline on 03708 506506 if you think this is incorrect.")
      end
    end

    context "when the registration is not ACTIVE" do
      it "cannot be renewed" do
        subject.registration.metaData.first.update(status: "REVOKED")

        expect(subject.can_renew?).to eq(false)
        expect(subject.registration.errors.first[1]).to eq("This number is not registered. Call our helpline on 03708 506506 if you think this is incorrect.")
      end
    end

    context "when the registration expires outside the renewal window" do
      it "cannot be renewed" do
        expiry_date = (3.months.from_now + 2.day).to_date
        subject.registration.expires_on = date_to_utc_milliseconds(expiry_date)
        renew_from = ExpiryDateService.new(expiry_date).date_can_renew_from

        expect(subject.can_renew?).to eq(false)
        expect(subject.registration.errors.first[1]).to eq("This registration is not eligible for renewal until #{renew_from.to_formatted_s(:day_month_year)}.")
      end
    end

    context "when the registration is expired" do
      before { subject.registration.metaData.first.update(status: "EXPIRED") }

      context "and we are outside the 'grace window'" do
        it "cannot be renewed" do
          subject.registration.expires_on = date_to_utc_milliseconds(Date.today - Rails.configuration.registration_grace_window)

          expect(subject.can_renew?).to eq(false)
          expect(subject.registration.errors.first[1]).to eq("The registration number you entered has expired")
        end
      end

      context "and we are inside the 'grace window'" do
        before { subject.registration.expires_on = date_to_utc_milliseconds(Date.today) }
        context "and the status is 'REVOKED'" do
          it "cannot be renewed" do
            subject.registration.metaData.first.update(status: "REVOKED")

            expect(subject.can_renew?).to eq(false)
          end
        end

        it "can be renewed" do
          expect(subject.can_renew?).to eq(true)
        end
      end
    end
  end
end
