require 'spec_helper'

describe PaymentsExport do

  let(:report) { Report.new(from: '2016-01-01', to: '2050-01-01') }
  let(:registrations) do
    [
      Registration.ctor(build(:registration, :creating, :with_finance_details).attributes).save
    ]
  end
  let(:payments_export) { PaymentsExport.new(report, registrations) }
  let(:headings) {
    [
      "Registration",
      "Trading name",
      "Registration status",
      "Route",
      "Transaction date",
      "Order code",
      "Charge type",
      "Charge amount",
      "Charge updated by",
      "Payment type",
      "Reference",
      "Payment amount",
      "Comments",
      "Payment updated by",
      "Payment received",
      "Balance"
    ]
  }

  describe "#generate_csv" do
    it "includes headings in the returned CSV string" do
      expect(payments_export.generate_csv).to include(headings.join(','))
    end
    it "includes details of the registrations" do
      skip "This test only works when run alone. Needs investigating."
      expect(payments_export.generate_csv).to include(registrations.first.companyName)
    end
  end

end
