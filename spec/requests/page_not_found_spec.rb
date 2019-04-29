# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Page not found", type: :request do
  describe "GET /this-page-does-not-exist" do
    it "redirects to `/errors/404`" do
      rails_respond_without_detailed_exceptions do
        get "/this-page-does-not-exist"

        expect(response.code).to eq("404")
      end
    end
  end
end
