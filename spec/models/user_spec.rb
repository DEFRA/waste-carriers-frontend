require 'spec_helper'
require 'cancan/matchers'

describe User do
  describe 'abilities' do
    context 'waste carrier user' do
      let(:user) { FactoryGirl.create :user }

      context 'own certificate' do
        let(:registration) { Registration.new }
        subject(:ability) { Ability.new(user) }

        before do
          allow(registration).to receive(:user).and_return(user)
          allow(registration).to receive(:tier).and_return('LOWER')
        end

        it { should be_able_to(:print, registration) }
      end

      context 'certificate for other waste carrier' do
        let(:other_user) { FactoryGirl.build :user }
        let(:registration) { double(user: other_user) }
        subject(:ability) { Ability.new(user) }

        it { should_not be_able_to(:print, registration) }
      end

      context 'upper tier' do
        context 'paid' do
          let(:registration) { Registration.new }
          subject(:ability) { Ability.new(user) }

          before do
            allow(registration).to receive(:user).and_return(user)
            allow(registration).to receive(:paid_in_full?).and_return(true)
            allow(registration).to receive(:tier).and_return('UPPER')
          end

          it { should be_able_to(:print, registration) }
        end

        context 'unpaid' do
          let(:registration) { Registration.new }
          subject(:ability) { Ability.new(user) }

          before do
            allow(registration).to receive(:user).and_return(user)
            allow(registration).to receive(:paid_in_full?).and_return(false)
            allow(registration).to receive(:tier).and_return('UPPER')
          end

          it { should_not be_able_to(:print, registration) }
        end
      end
    end
  end

  describe '#confirmed?' do
    context 'missing confirmed_at' do
      before do
        subject.confirmed_at = nil
      end

      it { should_not be_confirmed }
    end

    context 'with confirmed_at' do
      before do
        subject.confirmed_at = 1.day.ago
      end

      it { should be_confirmed }
    end
  end
end