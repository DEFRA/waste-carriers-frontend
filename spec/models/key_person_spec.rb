require 'spec_helper'

describe KeyPerson do
  it { should validate_presence_of(:first_name).with_message(/You must enter/) }
  it { should validate_presence_of(:last_name).with_message(/You must enter/) }

  it { should validate_presence_of(:dob_day).with_message(/You must enter/) }
  it { should validate_presence_of(:dob_month).with_message(/You must enter/) }
  it { should validate_presence_of(:dob_year).with_message(/You must enter/) }

  describe 'dob' do
    context 'past within 18 years' do
      Timecop.freeze('5 Jul 2014'.to_date) do
        it { should_not allow_value('4 Jul 2014'.to_date).for(:dob).with_message(/You must be over 18 to use this service/) }
      end
    end

    context 'past outside 18 years' do
      Timecop.freeze('5 Jul 2014'.to_date) do
        it { should allow_value('4 Jul 1996'.to_date).for(:dob) }
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
