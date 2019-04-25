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
        TestMailer.basic_text_email(recipient).deliver_now
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
        TestMailer.basic_text_email(first_recipient).deliver_now
        TestMailer.basic_text_email(second_recipient).deliver_now
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

    context "when handling emails with different formats" do
      let(:result) { instance.last_email_json }
      before(:each) { instance.reset }

      context "where the email is not multipart" do
        context "and is plain text" do
          it "is able to extract the body content" do
            TestMailer.basic_text_email("test@example.com").deliver_now
            parsed_result = JSON.parse(result)

            expect(parsed_result["last_email"].keys).to match_array(expected_attributes)
            expect(parsed_result["last_email"]["body"]).to eq("Test email")
          end
        end

        context "and is html" do
          it "is able to extract the body content" do
            TestMailer.basic_html_email("test@example.com").deliver_now
            parsed_result = JSON.parse(result)

            expect(parsed_result["last_email"].keys).to match_array(expected_attributes)
            expect(parsed_result["last_email"]["body"]).to eq("<h1>Test email</h1>")
          end
        end
      end

      context "where the email is multipart" do
        context "but just contains a plain text part" do
          it "is able to extract the body content" do
            TestMailer.multipart_text_email("test@example.com").deliver_now
            parsed_result = JSON.parse(result)

            expect(parsed_result["last_email"].keys).to match_array(expected_attributes)
            expect(parsed_result["last_email"]["body"]).to start_with("This is a text test email")
          end
        end

        context "but just contains a html part" do
          it "is able to extract the body content" do
            TestMailer.multipart_html_email("test@example.com").deliver_now
            parsed_result = JSON.parse(result)

            expect(parsed_result["last_email"].keys).to match_array(expected_attributes)
            expect(parsed_result["last_email"]["body"]).to start_with("<p>This is a html test email")
          end
        end

        it "extracts the plain text body content" do
          TestMailer.multipart_email("test@example.com").deliver_now
          parsed_result = JSON.parse(result)

          expect(parsed_result["last_email"].keys).to match_array(expected_attributes)
          expect(parsed_result["last_email"]["body"]).to start_with("This is a text test email")
        end
      end
    end
  end
end
