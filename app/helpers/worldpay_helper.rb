# Module including helper functions for Worldpay integration, using the WorldPay XML Redirect model
# See the WorldPay XML Redirect Guide for details:
# http://support.worldpay.com/support/kb/gg/pdf/rxml.pdf

require 'uri'
require 'net/http'
require 'base64'
require 'open-uri'

module WorldpayHelper

    def redirect_to_worldpay(registration)
      #puts '*******'
      #puts registration.to_s
      #puts '*******'

      xml = create_xml(registration)
      logger.info 'About to contact WorldPay: XML username = ' + worldpay_xml_username
      logger.info 'Sending XML to Worldpay: ' + xml

      response = send_xml(xml)
      logger.info 'Received response from Worldpay: ' + response.body.to_s
      redirect_url = get_redirect_url(parse_xml(response.body))
      redirect_to redirect_url
    end

    # Construct an XML message according to the Worldpay DTD    
    def create_xml(registration)
      merchantCode = worldpay_merchant_code
      orderCode = Time.now.to_i.to_s
      orderValue = registration.total_fee
      #TODO Remove pre-populated shopper values once Worldpay has been reconfigured not to require address details
      orderDescription = 'Your Waste Carrier Registration'
      orderContent = 'Waste Carrier Registration' + ' ' + registration.regIdentifier.to_s
      shopperEmail = registration.accountEmail || ''
      shopperFirstName = 'Joe'
      shopperLastName = 'Bloggs'
      shopperAddress1 = 'Test Street 123 - To be removed'
      shopperPostalCode = 'BS1 5AH'
      shopperCity = 'Bristol'
      shopperCountryCode = 'GB'

      xml = "<?xml version=\"1.0\"?>\n"
      xml << "<!DOCTYPE paymentService PUBLIC '-//WorldPay/DTD WorldPay PaymentService v1/EN' 'http://dtd.worldpay.com/paymentService_v1.dtd'>\n"
      xml << "<paymentService version=\"1.4\" merchantCode=\"" + merchantCode + "\">\n"
      xml << "<submit>\n"
      xml << "<order orderCode=\"" + orderCode + "\">\n"
      xml << "<description>" + orderDescription + "</description>\n"
      xml << "<amount currencyCode=\"GBP\" value=\"" + orderValue.to_s + "\" exponent=\"2\"/>\n"
      xml << '<orderContent>' + orderContent + '</orderContent>' + "\n"
      xml << '<paymentMethodMask>'
#      xml << "<include code=\"ONLINE\"/>"
      xml << "<include code=\"VISA-SSL\"/>"
      xml << "<include code=\"MAESTRO-SSL\"/>"
      xml << "<include code=\"ECMC-SSL\"/>"
      xml << '</paymentMethodMask>' + "\n"
      xml << '<shopper>' + "\n"
      xml << '<shopperEmailAddress>' + shopperEmail + '</shopperEmailAddress>' + "\n"
      xml << '</shopper>' + "\n"
      xml << '<billingAddress>'
      xml << '<address>'
      xml << '<firstName>' + shopperFirstName + '</firstName>'
      xml << '<lastName>' + shopperLastName + '</lastName>'
      xml << '<address1>' + shopperAddress1 + '</address1>'
      xml << '<postalCode>' + shopperPostalCode + '</postalCode>'
      xml << '<city>' + shopperCity + '</city>'
      xml << '<countryCode>' + shopperCountryCode + '</countryCode>'
      xml << '</address>'
      xml << '</billingAddress>' + "\n"
      xml << '</order>' + "\n"
      xml << '</submit>' + "\n"
      xml << '</paymentService>' + "\n"
      xml
    end

    def send_xml(xml)
      username = worldpay_xml_username
      password = worldpay_xml_password
      test_uri = Rails.configuration.worldpay_uri
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
      success_url = URI::encode(worldpay_success_url)
      failure_url = URI::encode(worldpay_failure_url)
      pending_url = URI::encode(worldpay_pending_url)
      cancel_url = URI::encode(worldpay_cancel_url)

      # Note: The URL returned from WP already has some query parameters e.g. for the orderCode
      redirect_args = ''
      redirect_args << '&successURL=' + success_url
      redirect_args << '&failureURL=' + failure_url
      redirect_args << '&pendingURL=' + pending_url
      redirect_args << '&cancelURL=' + cancel_url
      url_with_args = url + redirect_args

      url_with_args
    end

    # Select the merchant code to use based on the request. For assisted digital, an agency user must be signed in.
    def worldpay_merchant_code
      if agency_user_signed_in?
        Rails.configuration.worldpay_moto_merchantcode
      else
        Rails.configuration.worldpay_ecom_merchantcode
      end
    end  

    def worldpay_xml_username
      if agency_user_signed_in?
        Rails.configuration.worldpay_moto_username
      else
        Rails.configuration.worldpay_ecom_username
      end
    end

    def worldpay_xml_password
      if agency_user_signed_in?
        Rails.configuration.worldpay_moto_password
      else
        Rails.configuration.worldpay_ecom_password
      end
    end

    def worldpay_mac_secret
      if agency_user_signed_in?
        Rails.configuration.worldpay_moto_macsecret
      else
        Rails.configuration.worldpay_ecom_macsecret
      end
    end

    # Validate the MAC, as per section 7.2.2. of the Worldpay XML Redirection Guide
    # (see http://support.worldpay.com/support/kb/gg/pdf/rxml.pdf)
    def validate_worldpay_return_parameters(orderKey, paymentAmount, paymentCurrency, paymentStatus, mac)
      mac_secret = worldpay_mac_secret
      data = orderKey + paymentAmount + paymentCurrency + paymentStatus + mac_secret
      digest = Digest::MD5.hexdigest(data)
      logger.info 'MD5 digest = ' + digest.to_s
      logger.info 'MAC = ' + mac
      digest.to_s.eql? mac
    end
end
