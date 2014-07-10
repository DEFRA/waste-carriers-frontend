require 'spec_helper'
require 'cancan/matchers'

describe User do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }

    context 'waste carrier user' do
      let(:user) { FactoryGirl.build :user }

      context 'own certificate' do
        let(:registration) { double(user: user) }

        it { should be_able_to(:print, registration) }
      end

      context 'certificate for other waste carrier' do
        let(:registration) { double(user: FactoryGirl.build(:user) ) }

        it { should_not be_able_to(:print, registration) }
      end

      context 'upper tier' do
        context 'paid' do
          let(:registration) { double(user: user, paid_in_full?: true ) }

          it { should be_able_to(:print, registration) }
        end

        context 'unpaid' do
          let(:registration) { double(user: user, paid_in_full?: false ) }

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