require 'spec_helper'
require 'cancan/matchers'

describe User do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }

    context 'waste carrier user' do
      let(:user) { Factory(:user) }

      it{ should be_able_to(:x, Registration.new) }
    end

    context 'NCCC agency user' do
      let(:user) { Factory(:agency_user) }

      it{ should be_able_to(:x, Registration.new) }
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