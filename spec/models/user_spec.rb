require 'spec_helper'

describe User do
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