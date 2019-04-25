# frozen_string_literal: true

require "spec_helper"

RSpec.describe LastEmailCache do
  subject(:instance) { described_class.instance }

  describe "#last_email_json" do
    let(:expected_attributes) { %w[date from to bcc cc reply_to subject body attachments] }

    context "when the no emails have been sent" do
      before(:each) { instance.reset }
      let(:result) { instance.last_email_json }

      it "returns a JSON string" do
        expect(result).to be_a(String)
        expect { JSON.parse(result) }.to_not raise_error
      end

      it "responds with an error message" do
        parsed_result = JSON.parse(result)
        expect(parsed_result.key?("error")).to eq(true)
        expect(parsed_result["error"]).to eq("No emails sent.")
      end
    end

    context "when an email has been sent" do
      let(:result) { instance.last_email_json }
      let(:recipient) { "test@example.com" }
      before(:each) do
        instance.reset
        generate_test_email(recipient).deliver_now
      end

      it "returns a JSON string" do
        expect(result).to be_a(String)
        expect { JSON.parse(result) }.to_not raise_error
      end

      it "responds with the email as JSON" do
        parsed_result = JSON.parse(result)
        expect(parsed_result["last_email"].keys).to match_array(expected_attributes)
        expect(parsed_result["last_email"]["to"]).to eq([recipient])
      end
    end

    context "when multiple emails have been sent" do
      let(:result) { instance.last_email_json }
      let(:first_recipient) { "test@example.com" }
      let(:second_recipient) { "joe.bloggs@example.com" }
      before(:each) do
        instance.reset
        generate_test_email(first_recipient).deliver_now
        generate_test_email(second_recipient).deliver_now
      end

      it "returns a JSON string" do
        expect(result).to be_a(String)
        expect { JSON.parse(result) }.to_not raise_error
      end

      it "responds with the most recent email as JSON" do
        parsed_result = JSON.parse(result)
        expect(parsed_result["last_email"].keys).to match_array(expected_attributes)
        expect(parsed_result["last_email"]["to"]).to eq([second_recipient])
      end
    end
  end
end
