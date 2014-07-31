require 'spec_helper'

describe KeyPerson do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }

  it { should validate_presence_of(:dob_day) }
  it { should validate_presence_of(:dob_month) }
  it { should validate_presence_of(:dob_year) }

  describe 'dob' do
    context 'past' do
      Timecop.freeze('5 Jul 2014'.to_date) do
        it { should allow_value('4 Jul 2014'.to_date).for(:dob) }
      end
    end

    context 'today' do
      Timecop.freeze('5 Jul 2014'.to_date) do
        xit { should_not allow_value('5 Jul 2014'.to_date).for(:dob) }
      end
    end

    context 'future' do
      Timecop.freeze('5 Jul 2014'.to_date) do
        xit { should_not allow_value('6 Jul 2014'.to_date).for(:dob) }
      end
    end
  end
end