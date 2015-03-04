require 'spec_helper'

describe KeyPerson do
  it { should validate_presence_of(:first_name).with_message(/You must enter/) }
  it { should validate_presence_of(:last_name).with_message(/You must enter/) }

  it { should validate_presence_of(:dob_day).with_message(/You must enter/) }
  it { should validate_presence_of(:dob_month).with_message(/You must enter/) }
  it { should validate_presence_of(:dob_year).with_message(/You must enter/) }

  describe 'dob' do
    context 'in the past but within 18 years' do
      Timecop.freeze('5 Jul 2014'.to_date) do
        it { should_not allow_value('4 Jul 2014'.to_date).for(:dob).with_message(/You must be over 18 to use this service/) }
      end
    end

    context 'in the past past but outside 18 years' do
      Timecop.freeze('5 Jul 2014'.to_date) do
        it { should allow_value('4 Jul 1996'.to_date).for(:dob) }
      end
    end

    context 'in the past but within 16 years' do
      before { subject.position = 'Director' }

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          expect(subject).not_to allow_value('6 Jul 2014'.to_date).for(:dob).with_message('You must be over 16 to be a director of a private limited company in the UK')
        end
      end
    end

    context 'in the past but outside 16 years' do
      before { subject.position = 'Director' }

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          expect(subject).to allow_value('4 Jul 1998'.to_date).for(:dob)
        end
      end
    end

    context 'in the past but within 130 years' do
      Timecop.freeze('5 Jul 2014'.to_date) do
        it { should allow_value('5 Jul 1994'.to_date).for(:dob) }
      end
    end

    context 'in the past but past outside 130 years' do
      Timecop.freeze('5 Jul 2014'.to_date) do
        it { should_not allow_value('4 Jul 1880'.to_date).for(:dob) }
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
