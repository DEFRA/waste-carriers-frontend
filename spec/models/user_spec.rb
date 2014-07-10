require 'spec_helper'
require 'cancan/matchers'

describe User do
  describe 'abilities' do
    context 'waste carrier user' do
      context 'own certificate' do
        let(:user) { FactoryGirl.build :user }
        let(:registration) { double(user: user) }
        subject(:ability) { Ability.new(user) }

        it { should be_able_to(:print, registration) }
      end

      context 'certificate for other waste carrier' do
        let(:user) { FactoryGirl.build :user }
        let(:other_user) { FactoryGirl.build :user }
        let(:registration) { double(user: other_user) }
        subject(:ability) { Ability.new(user) }

        it { should_not be_able_to(:print, registration) }
      end

      context 'upper tier' do
        context 'paid' do
          let(:user) { FactoryGirl.build :user }
          let(:registration) { double(user: user, paid_in_full?: true, tier: 'UPPER' ) }
          subject(:ability) { Ability.new(user) }

          it { should be_able_to(:print, registration) }
        end

        context 'unpaid' do
          let(:user) { FactoryGirl.build :user }
          let(:registration) { double(user: user, paid_in_full?: false, tier: 'UPPER' ) }
          subject(:ability) { Ability.new(user) }

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