require 'json'

module RegistrationsHelper

  def validation_for(model, attribute)
    if model.errors[attribute].any?
      # Note: Calling raw() forces the characters to be un-escaped and thus HTML elements can be defined here
      raw("<span class=\"error-text\">#{model.errors[attribute].first}</span>")
    else
      ""
    end
  end

  # Strip off leading/trailing whitespace and force to uppercase
  def formatIRRenewalNumber(numberIn)
    numberOut = numberIn.strip.upcase
  end

  def format_address(address)
    if address.postcode.nil?
      # Print International address
      "#{h(address.addressLine1)}<br />#{h(address.addressLine2)}<br />#{h(address.addressLine3)}<br />#{h(address.addressLine4)}<br />#{h(address.country)}".html_safe
    else
      if address.addressLine2.present?
        # Print UK Address Including Address line 2 (as its optional but been
        # populated)
        if address.dependentLocality.present?
          "#{h(address.houseNumber)} #{h(address.addressLine2)}<br />#{h(address.addressLine2)}<br />#{h(address.dependentLocality)}<br />#{h(address.townCity)}<br />#{h(address.postcode)}".html_safe
        else
          "#{h(address.houseNumber)} #{h(address.addressLine1)}<br />#{h(address.addressLine2)}<br />#{h(address.townCity)}<br />#{h(address.postcode)}".html_safe
        end
      else
        # Print UK Address
        if address.dependentLocality.present?
          "#{h(address.houseNumber)} #{h(address.addressLine1)}<br />#{h(address.dependentLocality)}<br />#{h(address.townCity)}<br />#{h(address.postcode)}".html_safe
        else
          "#{h(address.houseNumber)} #{h(address.addressLine1)}<br />#{h(address.townCity)}<br />#{h(address.postcode)}".html_safe
        end
      end
    end
  end

  def format_email(emailIn)
    emailIn.downcase
  end

  def one_full_message_per_invalid_attribute(registration)
    hash_without_base = registration.errors.messages.except :base

    hash_without_base.each_key do |key|
      singleton_array_of_first_element = Array.wrap(registration.errors.get(key).first)
      registration.errors.set key, singleton_array_of_first_element
    end

    registration.errors.full_messages
  end


  def one_full_message_with_key_per_invalid_attribute(registration)
    hash_without_base = registration.errors.messages.except :base
    errors_with_keys = []

    hash_without_base.each_key do |key|
      singleton_array_of_first_element = Array.wrap(registration.errors.get(key).first)
      registration.errors.set key, singleton_array_of_first_element
      logger.debug "++++++++++++++++++++++++++ #{singleton_array_of_first_element.class}"
      errors_with_keys << {key =>  "#{key} #{singleton_array_of_first_element[0]}" }

    end

    errors_with_keys
  end

  def isSmallWriteOffAvailable(registration)
    registration.finance_details.first and (Payment.isSmallWriteOff( registration.finance_details.first.balance) == true)
  end

  def isLargeWriteOffAvailable(registration)
    registration.finance_details.first.balance.to_i != 0
  end

  def isRefundAvailable(registration)
    registration.finance_details.first.balance.to_f < 0
  end

  def set_registration_from_uuid_or_reg_uuid(refresh_from_services: false)
    uuid = params[:reg_uuid]
    # Check redis
    @registration = Registration.find(reg_uuid: uuid).first
    # Check the services / mongo
    @registration = Registration.find_by_id(uuid) if @registration.blank?
    # Force refresh from the services if possible and requested
    @registration = Registration.find_by_id(@registration.uuid) if @registration.present? && refresh_from_services
    render_not_found and return unless @registration.present?
  end

  def setup_registration(current_step, no_update = false)
    # This method is called throughout the system to set the registration
    # model from a Redis find.
    # Then the registration params are added to the model and the current step
    # set, which is the way the application performs validation on the model.

    reg_uuid = params[:reg_uuid]
    raise 'Registration UUID Param not found' unless reg_uuid.present?

    @registration = Registration.find(reg_uuid: reg_uuid).first

    render_not_found and return unless @registration.present?

    @registration.add(params[:registration]) unless no_update

    # Force contact email to lower case
    @registration.contactEmail = format_email(@registration.contactEmail) if @registration.contactEmail

    @registration.save
    @registration.current_step = current_step
  end

  # A simple version of setup_registration to set the registration model from
  # Redis
  def new_step_action(current_step)
    reg_uuid = params[:reg_uuid]
    raise 'Registration UUID Param not found' unless reg_uuid.present?
    @registration = Registration.find(reg_uuid: reg_uuid).first
    render_not_found and return unless @registration.present?
    @registration.current_step = current_step
  end

  def clear_edit_session
    session.delete(:edit_mode)
    session.delete(:edit_result)
  end

  def clear_registration_session
    # Clear session variables
    session.delete(:registration_id)
    session.delete(:registration_uuid)
    session.delete(:at_mid_registration_signin_step)

    # Clear session variables used for Google Analytics.
    session.delete(:ga_is_renewal)
    session.delete(:ga_tier)
    session.delete(:ga_convictions)
    session.delete(:ga_payment_method)
  end

  def give_meaning_to_reg_type(attr_value)
    case attr_value
    when 'carrier_broker_dealer'
      I18n.t('registration_type.show.readable_carrier_broker_dealer')
    when 'carrier_dealer'
      I18n.t('registration_type.show.readable_carrier_dealer')
    when 'broker_dealer'
      I18n.t('registration_type.show.readable_broker_dealer')
    end
  end

  # Defines the list of classes for the complete summary

  COMPLETE_STATUSES = [STATUS_COMPLETE = 'complete',
                       STATUS_COMPLETE_LOWER = 'complete lower',
                       STATUS_CRIMINALLY_SUSPECT = 'criminallySuspect',
                       STATUS_ALMOST_COMPLETE = 'almostComplete',
                       STATUS_READY = 'ready']


  def getConfirmationType
    confirmationType = nil

    # These must match the css classes they related to:
    # criminally_suspect_class = 'criminallySuspect'
    # almost_complete_class = 'almostComplete'
    # complete_class = 'complete'
    # complete_lower_class = 'complete lower'

    if @registration.upper?

      if @registration.paid_in_full?
        logger.debug "registration.paid_in_full"
      else
        logger.debug "registration NOT paid_in_full"
      end

      # Rules to determine registration status -
      #   If Conviction(s) declared & paid in full (must be via World Pay)
      #     mark as conviction(s) check pending
      #   else if registration has not been paid in full (must be via Bank Transfer)
      #       mark registration as almost complete
      #   else no convictions & paid in full (via World Pay)
      #       mark registration as complete
      if @registration.is_awaiting_conviction_confirmation? && @registration.paid_in_full?
        confirmationType = STATUS_CRIMINALLY_SUSPECT
      elsif !@registration.paid_in_full?
        confirmationType = STATUS_ALMOST_COMPLETE
      else
        confirmationType = STATUS_COMPLETE
      end
    else # lower registration
      confirmationType = STATUS_COMPLETE_LOWER if @registration.is_active?
    end

    return confirmationType
  end

  # Sets a flag in the session indicating how the user wants to pay (bank transfer or credit card), or clears
  # the flag if this is currently unknown.  Only used by Google Analytics.
  def set_google_analytics_payment_indicator(session, order)
    session.delete(:ga_payment_method)
    if order
      if order.is_online_payment?
        session[:ga_payment_method] = 'cc'
      elsif order.isOfflinePayment?
        session[:ga_payment_method] = 'bacs'
      end
    end
  end

  # Sets a flag in the session based on the user's answer to the has-relevant-convictions question, or clears
  # the flag if the answer is currently unknown.  Only used by Google Analytics.
  def set_google_analytics_convictions_indicator(session, registration)
    session.delete(:ga_convictions)
    if registration
      if registration.declaredConvictions == 'yes'
        session[:ga_convictions] = 'true'
      elsif registration.declaredConvictions == 'no'
        session[:ga_convictions] = 'false'
      end
    end
  end

  # Returns a hash containing the indicators used for Google Analytics.  Keys
  # will only be set when their value is known.
  def get_google_analytics_indicators_as_hash(session)
    result = {}
    result['renewal']     = session[:ga_is_renewal] if session.has_key?(:ga_is_renewal)
    result['tier']        = session[:ga_tier] if session.has_key?(:ga_tier)
    result['convictions'] = session[:ga_convictions] if session.has_key?(:ga_convictions)
    result['payment']     = session[:ga_payment_method] if session.has_key?(:ga_payment_method)
    result
  end

  # Returns a string of JSON containing indicators which help Google Analytics
  # identify which route through the site a visitor has taken.  Indicators are
  # only set when their value is known.
  def get_google_analytics_indicators_as_json(session)
    get_google_analytics_indicators_as_hash(session).to_json.html_safe
  end

  # Returns a string containing a partial URL that records a page-view in
  # Google Analytics, for browsers that don't support Javascript.
  def get_google_tag_manager_noscript_request(session)
    indicators = get_google_analytics_indicators_as_hash(session)
    request = format(
      '//www.googletagmanager.com/ns.html?id=%s',
      Rails.application.config.google_tag_manager_id
    ).html_safe

    unless indicators.empty?
      request << format('&%s', indicators.to_query).html_safe
    end

    request
  end

  def isCurrentRegistrationType(registrationNumber)
    # Strip leading and trailing whitespace from number
    regNo = registrationNumber.rstrip.lstrip

    # Just look at first 3 characters
    regNo = regNo[0, 3]

    # First 3 characters of reg ex
    current_reg_format = "CBD"

    # Check current format
    regNo.upcase.match(current_reg_format)
  end

  def isIRRegistrationType(registrationNumber)
    if registrationNumber
      # Strip leading and trailing whitespace from number
      regNo = registrationNumber.rstrip.lstrip

      # Just look at first 3 characters
      regNo = regNo[0, 3]

      # First 3 characters of reg ex
      legacy_reg_format = "CB/"

      # Check legacy format
      regNo.upcase.match(legacy_reg_format)
    else
      false
    end
  end

  # determines what we need to do after Smart Answers have been edited
  #
  # @param none
  # @return  [String] somthing
  def determine_smart_answers_route(edited_registration, original_registration)
    logger.debug "determine_smart_answers_route changed #{original_registration.businessType} to #{edited_registration.businessType}"

    if (original_registration.businessType != edited_registration.businessType) && \
        (['partnership', 'limitedCompany', 'publicBody'].include? edited_registration.businessType )
      {controller: :key_people, action: :key_people}
    else
      {action: :confirmation}
    end

  end

  # Show the confirm button unless the changes requested have been detected as not allowed
  def showConfirmButton?
    res = true
    if session[:edit_mode]
      if session[:edit_mode].to_i.eql? RegistrationsController::EditMode::EDIT
        if session[:edit_result].to_i.eql? RegistrationsController::EditResult::CHANGE_NOT_ALLOWED
          res = false
        end
      end
    end
    res
  end

  def proceed_as_upper
    @registration.tier = 'UPPER'
    @registration.save
    session[:ga_tier] = 'upper'
    redirect_to :registration_type
  end

  def proceed_as_lower
    @registration.tier = 'LOWER'
    @registration.save
    session[:ga_tier] = 'lower'
    redirect_to :business_details
  end
end
