require 'uri'
require 'net/http'
require 'base64'
require 'open-uri'

# Module including helper functions for Worldpay integration, using the WorldPay
# XML Redirect model. See the WorldPay XML Redirect Guide for details:
# http://support.worldpay.com/support/kb/gg/pdf/rxml.pdf
module WorldpayHelper
  # Construct an XML message according to the Worldpay DTD
  def create_xml(registration, order)
    merchant_code = worldpay_merchant_code
    order_code = order.orderCode
    order_value = order.totalAmount

    # TODO: Remove pre-populated shopper values once Worldpay has been
    # reconfigured not to require address details
    order_desc = I18n.t(
      'registrations.order.wpOrderDescription',
      identifier: registration.regIdentifier.to_s)
    order_content = order.description.encode(xml: :text)
    shopper_email = registration.accountEmail || ''
    shopper_first_name = registration.firstName.encode(xml: :text)
    shopper_lastname = registration.lastName.encode(xml: :text)

    address = worldpay_address(registration.registered_address)

    shopper_address_1 = address[:line_1].encode(xml: :text) if address[:line_1]
    shopper_address_2 = address[:line_2].encode(xml: :text) if address[:line_2]
    shopper_postcode = address[:postcode].encode(xml: :text) if address[:postcode]
    shopper_city = address[:town_city].encode(xml: :text) if address[:town_city]
    shopper_country_code = address[:country_code].encode(xml: :text) if address[:country_code]

    xml = "<?xml version=\"1.0\"?>\n"
    xml << "<!DOCTYPE paymentService PUBLIC '-//WorldPay/DTD WorldPay PaymentService v1/EN' 'http://dtd.worldpay.com/paymentService_v1.dtd'>\n"
    xml << "<paymentService version=\"1.4\" merchantCode=\"" + merchant_code + "\">\n"
    xml << "<submit>\n"
    xml << "<order orderCode=\"" + order_code + "\">\n"
    xml << "<description>" + order_desc + "</description>\n"
    xml << "<amount currencyCode=\"GBP\" value=\"" + order_value.to_s + "\" exponent=\"2\"/>\n"
    xml << '<orderContent>' + order_content + '</orderContent>' + "\n"
    xml << '<paymentMethodMask>'
    xml << "<include code=\"VISA-SSL\"/>"
    xml << "<include code=\"MAESTRO-SSL\"/>"
    xml << "<include code=\"ECMC-SSL\"/>"
    xml << '</paymentMethodMask>' + "\n"
    xml << '<shopper>' + "\n"
    xml << '<shopperEmailAddress>' + shopper_email + '</shopperEmailAddress>' + "\n"
    xml << '</shopper>' + "\n"
    xml << '<billingAddress>'
    xml << '<address>'
    xml << '<firstName>' + shopper_first_name.to_s + '</firstName>'
    xml << '<lastName>' + shopper_lastname.to_s + '</lastName>'
    xml << '<address1>' + shopper_address_1.to_s + '</address1>'
    xml << '<address2>' + shopper_address_2.to_s + '</address2>'
    xml << '<postalCode>' + shopper_postcode.to_s + '</postalCode>'
    xml << '<city>' + shopper_city.to_s + '</city>'
    xml << '<countryCode>' + shopper_country_code.to_s + '</countryCode>'
    xml << '</address>'
    xml << '</billingAddress>' + "\n"
    xml << '</order>' + "\n"
    xml << '</submit>' + "\n"
    xml << '</paymentService>' + "\n"
    xml
  end

  def worldpay_address(address)
    result = {}

    if address.houseNumber.blank?
      result[:line_1] = address.addressLine1
      result[:line_2] = address.addressLine2
    else
      result[:line_1] = address.houseNumber
      result[:line_2] = address.addressLine1
    end

    result[:town_city] = address.townCity
    result[:postcode] = address.postcode

    # We don't have to wrap the call to find_country_by_name as whether we pass
    # null in or it finds nothing the result is simply nil.
    # Worldpay will fail if we have no code hence we default to GB if no match
    # was found.
    country = Country.find_country_by_name(address.country)
    result[:country_code] = country.nil? ? 'GB' : country.gec

    result
  end

  def send_xml(xml)
    uri = URI(Rails.configuration.worldpay_uri)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    auth = Base64.encode64("#{worldpay_xml_username}:#{worldpay_xml_password}").to_s
    headers = { "Authorization" => "Basic #{auth}" }
    res = https.post(uri.path, xml, headers)
    return res if res.code == '200'
    logger.debug "Worldpay connection returned #{res.code} and failed."
    # This error is built using a tag.
    # The intended message contains html which renders when called from a view
    @order.errors.add(:exception, 'worldPayConnectionIssue')
    nil
  end

  def send_xml_with_username_password(xml, username, password)
    worldpay_service_uri = Rails.configuration.worldpay_uri
    uri = URI(worldpay_service_uri)
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

  def send_xml_with_username_password(xml, username, password)
    worldpay_service_uri = Rails.configuration.worldpay_uri
    uri = URI(worldpay_service_uri)
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    headers =
    {
      "Authorization" => 'Basic ' + Base64.encode64(username + ':' + password).to_s
    }
    response = https.post(uri.path, xml, headers)

    response
  end

  def get_redirect_url(doc)
    reference = doc.at_css('reference')
    if reference
      redirect_url = doc.at_css('reference').content
      redirect_url_with_args = set_redirect_arguments(redirect_url)
      redirect_url_with_args
    else
      logger.warn 'WORLDPAY::REDIRECT_ERROR - The was a problem redirecting to the payment pages.'
      errorMessage = ''
      begin

        #####################################################################################################
        #                                                                                                   #
        # NOTE:                                                                                             #
        # As this message is coming back from Worldpay and being shown to the user as an error              #
        # on screen, this will (thus far) always be in english and thus not be translatable.                #
        #                                                                                                   #
        #####################################################################################################

        errorMessage = doc.at_css('error').text
        logger.warn 'WORLDPAY::REDIRECT_ERROR - errorMessage: ' + errorMessage
      rescue => e
        Airbrake.notify(e)
        logger.error 'WORLDPAY::REDIRECT_ERROR - Cannot determine error message from response: ' + doc.to_s
      end
      flash.now[:notice] = I18n.t('errors.messages.worldpayErrorRedirect')
      flash[:notice] = I18n.t('errors.messages.worldpayErrorRedirect') + errorMessage.to_s
      redirect_url = upper_payment_path
    end
  end

  def set_redirect_arguments(url)
    success_url = URI::encode(worldpay_success_url)
    failure_url = URI::encode(worldpay_failure_url)
    pending_url = URI::encode(worldpay_pending_url)
    cancel_url = URI::encode(worldpay_cancel_url)

    # Note: The URL returned from WP already has some query parameters e.g. for the orderCode
    redirect_args = ''
    redirect_args << '&language=' + params[:locale] if params[:locale]
    redirect_args << '&successURL=' + success_url
    redirect_args << '&failureURL=' + failure_url
    redirect_args << '&pendingURL=' + pending_url
    redirect_args << '&cancelURL=' + cancel_url
    url_with_args = url + redirect_args

    url_with_args
  end

  # Select the merchant code to use based on the request. For assisted digital, an agency user must be signed in.
  def worldpay_merchant_code isMoto=nil
    if use_moto? isMoto
      Rails.configuration.worldpay_moto_merchantcode
    else
      Rails.configuration.worldpay_ecom_merchantcode
    end
  end

  def isMoto? orderMerchantCode
    if orderMerchantCode == Rails.configuration.worldpay_moto_merchantcode
      true
    elsif orderMerchantCode == Rails.configuration.worldpay_ecom_merchantcode
      false
    end
  end

  def worldpay_xml_username isMoto=nil
    if use_moto? isMoto
      Rails.configuration.worldpay_moto_username
    else
      Rails.configuration.worldpay_ecom_username
    end
  end

  def worldpay_xml_password isMoto=nil
    if use_moto? isMoto
      Rails.configuration.worldpay_moto_password
    else
      Rails.configuration.worldpay_ecom_password
    end
  end

  def worldpay_mac_secret isMoto=nil
    if use_moto? isMoto
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
    digest.to_s.eql? mac
  end

# @Deprecated
  def request_refund_from_worldpay
    #TODO Get values to be refunded from the registration and/or its relevant payment
    orderCode = 'Georg123'
    #TODO the merchantCode needs to come from the original payment as well
    merchantCode = worldpay_merchant_code
    currencyCode = "GBP"
    amount = 15400
    username = worldpay_xml_username
    password = worldpay_xml_password

    xml = create_refund_request_xml(merchantCode,orderCode,currencyCode,amount)
    logger.debug 'About to contact WorldPay for refund: XML username '
    logger.debug 'Sending refund request XML to Worldpay'

    response = send_xml_with_username_password(xml,username,password)
    @response = response.body
    logger.debug 'Received response from Worldpay'
    @response
  end

  # This function effectivly replaces the above function as it passes in the required order information
  def request_refund_from_worldpay(myOrderCode, ordersMerchantCode, myAmount)
    #TODO Get values to be refunded from the registration and/or its relevant payment
    orderCode = myOrderCode
    #TODO the merchantCode needs to come from the original payment as well
    merchantCode = ordersMerchantCode
    currencyCode = "GBP"
    amount = myAmount
    username = worldpay_xml_username isMoto?(ordersMerchantCode)
    password = worldpay_xml_password isMoto?(ordersMerchantCode)

    #xml = create_cancel_or_refund_request_xml(merchantCode,orderCode)
    xml = create_refund_request_xml(merchantCode, orderCode, currencyCode, amount)
    logger.debug 'About to contact WorldPay for refund'
    logger.debug 'Sending refund request XML to Worldpay'

    response = send_xml_with_username_password(xml,username,password)
    @response = response.body
    logger.debug 'Received response from Worldpay'
    @response
  end

  def responseOk? (responseBody)
    parse_xml(responseBody).css("paymentService reply ok").first.to_s.include?("ok")
  end

  # TEST: Replaced this with cancel_or_refund_request
  def create_refund_request_xml(merchantCode, orderCode, currencyCode, amount)
    xml = "<?xml version=\"1.0\"?>\n"
    xml << "<!DOCTYPE paymentService PUBLIC '-//WorldPay/DTD WorldPay PaymentService v1/EN' 'http://dtd.worldpay.com/paymentService_v1.dtd'>\n"
    xml << "<paymentService version=\"1.4\" merchantCode=\"" + merchantCode + "\">\n"
    xml << "<modify>\n"
    xml << "<orderModification orderCode=\"" + orderCode + "\">\n"
    xml << "<refund>\n"
    xml << "<amount value=\""+ amount.to_s + "\" currencyCode=\"" + currencyCode + "\" exponent=\"2\"/>"
    xml << "</refund>\n"
    xml << "</orderModification>\n"
    xml << "</modify>\n"
    xml << "</paymentService>\n"
    xml
  end

  def create_cancel_or_refund_request_xml(merchantCode, orderCode)
    xml = "<?xml version=\"1.0\"?>\n"
    xml << "<!DOCTYPE paymentService PUBLIC '-//WorldPay/DTD WorldPay PaymentService v1/EN' 'http://dtd.worldpay.com/paymentService_v1.dtd'>\n"
    xml << "<paymentService version=\"1.4\" merchantCode=\"" + merchantCode + "\">\n"
    xml << "<modify>\n"
    xml << "<orderModification orderCode=\"" + orderCode + "\">\n"
    xml << "<cancelOrRefund/>\n"
    xml << "</orderModification>\n"
    xml << "</modify>\n"
    xml << "</paymentService>\n"
    xml
  end

  def process_order_notification(notification)
    # TODO: This method appears to be unused. Remove?
    # logger.debug "Processing order notification: " + notification.to_s
  end

  def use_moto? isMoto
    #
    # REVIEW ME:
    # Remove the check for an agency user merchant code being different from external user and just use external user code
    #
    #agency_user_signed_in?
    if !isMoto.nil?
      isMoto
    else
      agency_user_signed_in?
    end
  end
end
