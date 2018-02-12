require 'spec_helper'

describe ApplicationHelper do
  describe '#date_can_renew_from' do
    context 'when the date passed in is 2018-03-25 and the renewal window is 3 months' do
      it 'returns a date of 2017-12-24' do
        Rails.configuration.stub(:registration_renewal_window).and_return(3.months)

        test_date = Date.parse("2018-03-25-T12:00:00.000Z")
        expect(helper.date_can_renew_from(test_date)).to eq(Date.new(2017,12,24))
      end
    end
  end
end
