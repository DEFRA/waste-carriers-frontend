# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Errors", type: :request do
  describe "GET /last-email" do
    context "when `Rails.configuration.use_last_email_cache` is \"true\"" do
      let(:recipient) { "test@example.com" }
      before do
        allow(Rails.configuration).to receive(:use_last_email_cache).and_return(true)
      end

      it "returns the JSON value of the LastEmailCache", inject_interceptor: LastEmailCache do
        TestMailer.basic_text_email(recipient).deliver_now
        get last_email_path
        result = JSON.parse(response.body)

        expect(result["last_email"]["to"]).to eq([recipient])
      end
    end

    context "when `Rails.configuration.use_last_email_cache` is \"false\"" do
      before { allow(Rails.configuration).to receive(:use_last_email_cache).and_return(false) }

      it "raises a routing error (404)" do
        expect { get "/last-email" }.to raise_error(ActionController::RoutingError)
      end
    end

    context "when `Rails.configuration.use_last_email_cache` is missing" do
      before { allow(Rails.configuration).to receive(:use_last_email_cache).and_return(nil) }

      it "raises a routing error (404)" do
        expect { get "/last-email" }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
