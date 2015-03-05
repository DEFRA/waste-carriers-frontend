require 'spec_helper'

describe KeyPerson do
  it { should validate_presence_of(:first_name).with_message(/You must enter/) }
  it { should validate_presence_of(:last_name).with_message(/You must enter/) }

  it { should validate_presence_of(:dob_day).with_message(/You must enter/) }
  it { should validate_presence_of(:dob_month).with_message(/You must enter/) }
  it { should validate_presence_of(:dob_year).with_message(/You must enter/) }

  describe 'dob' do

     context 'in the past but within 18 years' do
      before do
        subject.dob_day = '4'
        subject.dob_month = '7'
        subject.dob_year = '2014'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          expect(subject).not_to allow_value('4 Jul 2014'.to_date).for(:dob).with_message('You must be over 18 to use this service')
        end
      end
    end

    context 'in the past past but outside 18 years' do
      before do
        subject.dob_day = '4'
        subject.dob_month = '7'
        subject.dob_year = '1996'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          expect(subject).to allow_value('4 Jul 2014'.to_date).for(:dob)
        end
      end
    end

    context 'in the past but within 16 years' do
      before do
        subject.dob_day = '4'
        subject.dob_month = '7'
        subject.dob_year = '2014'
        subject.position = 'Director'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          expect(subject).not_to allow_value('4 Jul 2014'.to_date).for(:dob).with_message('You must be over 16 to be a director of a private limited company in the UK')
        end
      end
    end

    context 'in the past but outside 16 years' do
      before do
        subject.dob_day = '4'
        subject.dob_month = '7'
        subject.dob_year = '1998'
        subject.position = 'Director'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          expect(subject).to allow_value('4 Jul 1998'.to_date).for(:dob)
        end
      end
    end

    context 'in the past past but within 130 years' do
      before do
        subject.dob_day = '4'
        subject.dob_month = '7'
        subject.dob_year = '1996'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          expect(subject).to allow_value('4 Jul 1996'.to_date).for(:dob)
        end
      end
    end

    context 'in the past but outside 130 years' do
      before do
        subject.dob_day = '4'
        subject.dob_month = '7'
        subject.dob_year = '1884'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          expect(subject).not_to allow_value('4 Jul 1884'.to_date).for(:dob).with_message('You must enter a valid date')
        end
      end
    end

    context 'today' do
      Timecop.freeze('5 Jul 2014'.to_date) do
        xit { should_not allow_value('5 Jul 2014'.to_date).for(:dob) }
      end
    end

    context 'in the futute' do
      before do
        subject.dob_day = '6'
        subject.dob_month = '7'
        subject.dob_year = '2014'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          expect(subject).not_to allow_value('6 Jul 2014'.to_date).for(:dob).with_message('The date must be in the past')
        end
      end
    end
  end
end
