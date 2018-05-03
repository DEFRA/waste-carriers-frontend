require 'spec_helper'
require 'cancan/matchers'

describe User, type: :model do
  describe 'password field' do
    it_behaves_like 'password with strength restrictions'
  end

  describe 'abilities' do
    context 'waste carrier user' do
      let(:user) { FactoryGirl.create :user }

      context 'own certificate' do
        let(:registration) { Registration.ctor }
        subject(:ability) { Ability.new(user) }

        before do
          allow(registration).to receive(:user).and_return(user)
          allow(registration).to receive(:tier).and_return('LOWER')
        end

        it { is_expected.to be_able_to(:view, registration) }
      end

      context 'certificate for other waste carrier' do
        let(:other_user) { FactoryGirl.build :user }
        let(:registration) { Registration.ctor }
        subject(:ability) { Ability.new(user) }

        before do
          allow(registration).to receive(:user).and_return(other_user)
          allow(registration).to receive(:tier).and_return('LOWER')
        end

        it { is_expected.not_to be_able_to(:view, registration) }
      end

      context 'upper tier' do
        context 'paid' do
          let(:registration) { Registration.ctor }
          subject(:ability) { Ability.new(user) }

          before do
            allow(registration).to receive(:user).and_return(user)
            allow(registration).to receive(:paid_in_full?).and_return(true)
            allow(registration).to receive(:tier).and_return('UPPER')
          end

          it { is_expected.to be_able_to(:view, registration) }
        end

        context 'unpaid' do
          let(:registration) { Registration.ctor }
          subject(:ability) { Ability.new(user) }

          before do
            allow(registration).to receive(:user).and_return(user)
            allow(registration).to receive(:paid_in_full?).and_return(false)
            allow(registration).to receive(:tier).and_return('UPPER')
          end

          it { is_expected.not_to be_able_to(:view, registration) }
        end
      end
    end

    context 'NCCC user' do
      let(:agency_user) { FactoryGirl.create :agency_user }

      context 'unpaid upper tier' do
        let(:waste_carrier_user) { FactoryGirl.create :user }
        let(:registration) { Registration.ctor }
        subject(:ability) { Ability.new(agency_user) }

        before do
          allow(registration).to receive(:user).and_return(waste_carrier_user)
          allow(registration).to receive(:paid_in_full?).and_return(false)
          allow(registration).to receive(:tier).and_return('UPPER')
        end

        it { is_expected.to be_able_to(:view, registration) }
      end
    end
  end

  describe '#confirmed?' do
    context 'missing confirmed_at' do
      before do
        subject.confirmed_at = nil
      end

      it { is_expected.not_to be_confirmed }
    end

    context 'with confirmed_at' do
      before do
        subject.confirmed_at = 1.day.ago
      end

      it { is_expected.to be_confirmed }
    end
  end
end
