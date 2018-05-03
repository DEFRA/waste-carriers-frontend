require 'spec_helper'

describe KeyPerson do
  it { is_expected.to validate_presence_of(:first_name).with_message(/You must enter/) }
  it { is_expected.to validate_presence_of(:last_name).with_message(/You must enter/) }

  it { is_expected.to validate_presence_of(:dob_day).with_message(/You must enter/) }
  it { is_expected.to validate_presence_of(:dob_month).with_message(/You must enter/) }
  it { is_expected.to validate_presence_of(:dob_year).with_message(/You must enter/) }

  describe 'dob' do

     context 'in the past but within 17 years' do
      before do
        subject.dob_day = '6'
        subject.dob_month = '7'
        subject.dob_year = '1997'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          subject.valid?
          expect(subject.errors[:dob].size).to eq(1)
          expect(subject.errors[:dob]).to include('You must be over 17 to use this service')
        end
      end
    end

    context 'in the past past but outside 17 years' do
      before do
        subject.dob_day = '4'
        subject.dob_month = '7'
        subject.dob_year = '1997'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          subject.valid?
          expect(subject.errors[:dob].size).to eq(0)
        end
      end
    end

    context 'in the past but within 16 years' do
      before do
        subject.dob_day = '6'
        subject.dob_month = '7'
        subject.dob_year = '1998'
        subject.position = 'Director'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          subject.valid?
          expect(subject.errors[:dob].size).to eq(1)
          expect(subject.errors[:dob]).to include('You must be over 16 to be a director of a private limited company in the UK')
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
          subject.valid?
          expect(subject.errors[:dob].size).to eq(0)
        end
      end
    end

    context 'in the past past but within 110 years' do
      before do
        subject.dob_day = '6'
        subject.dob_month = '7'
        subject.dob_year = '1904'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          subject.valid?
          expect(subject.errors[:dob].size).to eq(0)
        end
      end
    end

    context 'in the past but outside 110 years' do
      before do
        subject.dob_day = '4'
        subject.dob_month = '7'
        subject.dob_year = '1904'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          subject.valid?
          expect(subject.errors[:dob].size).to eq(1)
          expect(subject.errors[:dob]).to include('You must enter a valid date')
        end
      end
    end

    context 'today' do
      before do
        subject.dob_day = '5'
        subject.dob_month = '7'
        subject.dob_year = '2014'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          subject.valid?
          expect(subject.errors[:dob].size).to eq(1)
        end
      end
    end

    context 'in the future' do
      before do
        subject.dob_day = '6'
        subject.dob_month = '7'
        subject.dob_year = '2014'
      end

      it do
        Timecop.freeze('5 Jul 2014'.to_date) do
          subject.valid?
          expect(subject.errors[:dob].size).to eq(1)
          expect(subject.errors[:dob]).to include('The date must be in the past')
        end
      end
    end
  end
end
