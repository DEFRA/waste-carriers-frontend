require "spec_helper"

RSpec.describe DateService do
  describe '#date_can_renew_from' do

    context 'when the renewal window is 3 months and the date provided is 2018-03-25' do
      before do
        Rails.configuration.stub(:registration_renewal_window).and_return(3.months)
      end

      subject { DateService.new(Date.parse("2018-03-25-T12:00:00.000Z")) }

      it 'returns a date of 2017-12-25' do
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
end
