# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Errors", type: :request do
  describe "GET /last-email" do
    context "when `Rails.configuration.use_last_email_cache` is \"true\"" do
      before { allow(Rails.configuration).to receive(:use_last_email_cache).and_return(true) }

      it "returns the JSON value of the LastEmailCache" do
        generate_test_email("test@example.com").deliver_now
        get last_email_path
        expect(response.body).to eq(LastEmailCache.instance.last_email_json)
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
