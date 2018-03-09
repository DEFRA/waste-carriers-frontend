require "spec_helper"

describe RenewalExtensionController, type: :controller do
  describe "GET #show" do
    let(:regisration) { Registration.create }

    context "when the url includes a registration number" do
      it "responds successfully with a HTTP 200 status code" do
        get :show, id: "CBDU10"
        expect(response.code).to eq("200")
      end

      it "renders the #show template" do
        get :show, id: "CBDU10"
        expect(response).to render_template('show')
      end
    end

    # Specifically added this context because we previously allowed access to
    # this page using either /renew or /renew/cbdu10 . As its no longer a static
    # page we want to reduce that flexibility, hence we want our tests to
    # indicate this behaviour is no longer allowed.
    context "when the url doesn't include a registration number" do
      it "causes an error" do
        expect { get :show }.to raise_error(ActionController::UrlGenerationError)
      end
    end
  end
end
