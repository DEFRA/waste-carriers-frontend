require "spec_helper"

RSpec.describe DateService do
  describe "#attributes" do

    context "when initialized with a date" do
      provided_date = Date.today
      subject { DateService.new(provided_date) }

      it "sets :source_date to that date" do
        expect(subject.source_date).to eq(provided_date)
      end
    end

    context "when initialized with nil" do
      subject { DateService.new(nil) }

      it "sets :source_date to the epoch" do
        expect(subject.source_date).to eq(Date.new(1970,1,1))
      end
    end

    context "when initialized with UTC time in milliseconds" do
      # Equivalent to 2018-03-25 14:35:27
      subject { DateService.new(1521984927000) }

      it "sets :source_date to the Mar 25 2018" do
        expect(subject.source_date).to eq(Date.new(2018,3,25))
      end
    end

    context "when initialized with a string that represents a UTC time in milliseconds" do
      # Equivalent to 2018-03-25 14:35:27
      subject { DateService.new("1521984927000") }

      it "sets :source_date to the Mar 25 2018" do
        expect(subject.source_date).to eq(Date.new(2018,3,25))
      end
    end
  end

  describe "#date_can_renew_from" do

    context "when the renewal window is 3 months and the date provided is 2018-03-25" do
      before do
        Rails.configuration.stub(:registration_renewal_window).and_return(3.months)
      end

      subject { DateService.new(Date.parse("2018-03-25-T12:00:00.000Z")) }

      it "returns a date of 2017-12-25" do
        expect(subject.date_can_renew_from).to eq(Date.new(2017,12,25))
      end
    end

  end

  describe "#expired?" do

    context "when the expiry date is yesterday" do
      subject { DateService.new(Date.yesterday) }

      it "should be expired" do
        expect(subject.expired?).to eq(true)
      end
    end

    context "when the expiry date is today" do
      subject { DateService.new(Date.today) }

      it "should be expired" do
        expect(subject.expired?).to eq(true)
      end
    end

    context "when the expiry date is tomorrow" do
      subject { DateService.new(Date.tomorrow) }

      it "should not be expired" do
        expect(subject.expired?).to eq(false)
      end
    end

  end

  describe "#in_renewal_window?" do

    context "when the renewal window is 3 months" do
      before do
        Rails.configuration.stub(:registration_renewal_window).and_return(3.months)
      end

      context "and the expiry date is 3 months and 2 days from today" do
        subject { DateService.new(3.months.from_now + 2.day) }

        it "should not be in the window" do
          expect(subject.in_renewal_window?).to eq(false)
        end
      end

      context "and the expiry date is 3 months and 1 day from today" do
        subject { DateService.new(3.months.from_now + 1.day) }

        it "should not be in the window" do
          expect(subject.in_renewal_window?).to eq(false)
        end
      end

      context "and the expiry date is 3 months from today" do
        subject { DateService.new(3.months.from_now) }

        it "should be in the window" do
          expect(subject.in_renewal_window?).to eq(true)
        end
      end

      context "and the expiry date is less than 3 months from today" do
        subject { DateService.new(3.months.from_now - 1.day) }

        it "should be in the window" do
          expect(subject.in_renewal_window?).to eq(true)
        end
      end
    end
  end

  describe ".date_as_day_ordinal_date_month_and_year" do
    context "when a valid date is provided" do
      it "should return the date as Wednesday 21st February 2018" do
        provided_date = Date.new(2018,2,21)
        result = DateService.date_as_day_ordinal_date_month_and_year(provided_date)
        expect(result).to eq("Wednesday 21st February 2018")
      end
    end

    context "when an invalid date is provided" do
      it "should return nil" do
        result = DateService.date_as_day_ordinal_date_month_and_year("foo")
        expect(result).to eq(nil)
      end
    end
  end

end
