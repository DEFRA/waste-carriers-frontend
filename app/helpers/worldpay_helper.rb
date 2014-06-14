# Module including helper functions for Worldpay integration, using the WorldPay XML Redirect model
# See the WorldPay XML Redirect Guide for details:
# http://support.worldpay.com/support/kb/gg/pdf/rxml.pdf

require 'uri'
require 'net/http'
require 'base64'
require 'open-uri'

module WorldpayHelper

    def redirect_to_worldpay
      xml = create_xml
      response = send_xml(xml)
      redirect_url = get_redirect_url(parse_xml(response.body))
      redirect_to redirect_url
    end

    # Construct an XML message according to the Worldpay DTD    
    def create_xml
      merchantCode = Rails.configuration.worldpay_moto_merchantcode
      orderCode = Time.now.to_i.to_s
      orderValue = '12345'
      orderDescription = 'Your Waste Carrier Registration'
      orderContent = 'Your lovely new Waste Carrier Registration'
      xml = "<?xml version=\"1.0\"?>"
      xml << "<!DOCTYPE paymentService PUBLIC '-//WorldPay/DTD WorldPay PaymentService v1/EN' 'http://dtd.worldpay.com/paymentService_v1.dtd'>"
      xml << "<paymentService version=\"1.4\" merchantCode=\"" + merchantCode + "\">"
      xml << "<submit>"
      xml << "<order orderCode=\"" + orderCode + "\">"
      xml << "<description>" + orderDescription + "</description>"
      xml << "<amount currencyCode=\"GBP\" value=\"" + orderValue + "\" exponent=\"2\"/>"
      xml << '<orderContent>' + orderContent + '</orderContent>'
      xml << '<paymentMethodMask>'
      xml << "<include code=\"ONLINE\"/>"
      xml << "<exclude code=\"MAESTRO-SSL\"/>"
      xml << "<exclude code=\"AMEX-SSL\"/>"
      xml << '</paymentMethodMask>'
      xml << '</order>'
      xml << '</submit>'
      xml << '</paymentService>'
      xml
    end

    def send_xml(xml)
      username = Rails.configuration.worldpay_moto_username
      password = Rails.configuration.worldpay_moto_password
      test_uri = 'https://secure-test.worldpay.com/jsp/merchant/xml/paymentService.jsp'
      uri = URI(test_uri)
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true
      headers = 
      {
        "Authorization" => 'Basic ' + Base64.encode64(username + ':' + password).to_s
      }
      response = https.post(uri.path, xml, headers)

      response
    end

    def parse_xml(xml)
      doc = Nokogiri::XML(xml)
    end

    def get_redirect_url(doc)
      reference = doc.at_css('reference')
      if reference
        redirect_url = doc.at_css('reference').content
        redirect_url_with_args = set_redirect_arguments(redirect_url)
        redirect_url_with_args
      else
        flash.now[:notice] = 'The was a problem redirecting to the payment pages.'
        redirect_url = upper_summary_path
      end
    end

    def set_redirect_arguments(url)
      success_url = URI::encode("http://localhost:3000/worldpay/success")
      failure_url = URI::encode("http://localhost:3000/worldpay/failure")
      pending_url = URI::encode("http://localhost:3000/worldpay/pending")
      cancel_url = URI::encode("http://localhost:3000/worldpay/cancel")

      # Note: The URL returned from WP already has some query parameters e.g. for the orderCode
      redirect_args = ''
      redirect_args << '&successURL=' + success_url
      redirect_args << '&failureURL=' + failure_url
      redirect_args << '&pendingURL=' + pending_url
      redirect_args << '&cancelURL=' + cancel_url
      url_with_args = url + redirect_args

      puts 'GGG ' + url_with_args

      url_with_args
    end

end
