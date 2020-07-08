# frozen_string_literal: true

require "spec_helper"

RSpec.describe FeatureToggle do
  describe ".active?" do
    before do
      ENV["ENV_VARIABLE_TEST_FEATURE"] = "true"
      allow(FeatureToggle).to receive(:file_path) { "spec/support/feature_toggles.yml" }
    end

    context "when a record exists with the given key" do
      let(:key) { "toggle_1" }

      before do
        create(:feature_toggle, key: key, active: active)
      end

      context "and the toggle is active" do
        let(:active) { true }

        it "returns true" do
          expect(described_class.active?(key)).to eq(true)
        end
      end

      context "and the toggle is not active" do
        let(:active) { false }

        it "returns false" do
          expect(described_class.active?(key)).to eq(false)
        end
      end
    end

    context "when a record does not exist with the given key" do
      context "and a feature toggle config exists" do
        context "and it is configured as active" do
          let(:toggle) { {"active_test_feature"=>{"active"=>true}} }

          it "returns true" do
            expect(described_class.active?("active_test_feature")).to be_truthy
          end

          it "accept either strings or syms" do
            expect(described_class.active?(:active_test_feature)).to be_truthy
          end
        end

        context "and it is configured as not active" do
          it "returns false" do
            expect(described_class.active?("not_active_test_feature")).to be_falsey
          end
        end

        context "and the feature toggle contains a typo in the return value" do
          it "returns false" do
            expect(described_class.active?("broken_test_feature")).to be_falsey
          end
        end

        context "and the feature toggle contains a typo in the structure level" do
          it "returns false" do
            expect(described_class.active?("broken_test_feature_2")).to be_falsey
          end
        end

        context "and the feature toggle is a string containing 'true'" do
          it "returns true" do
            expect(described_class.active?("string_true_test_feature")).to be_truthy
          end
        end

        context "and the feature toggle is an environment variable" do
          it "returns true" do
            expect(described_class.active?("env_variable_test_feature")).to be_truthy
          end
        end
      end

      context "and a feature toggle config does not exist" do
        it "returns false" do
          expect(described_class.active?("i_do_not_exist")).to be_falsey
        end
      end
    end
  end
end
