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

  def format_address(model)
    if model.postcode.nil?
      # Print International address
      "#{h(model.streetLine1)}<br />#{h(model.streetLine2)}<br />#{h(model.streetLine3)}<br />#{h(model.streetLine4)}<br />#{h(model.country)}".html_safe
    else
      if model.streetLine2.present?
        # Print UK Address Including Street line 2 (as its optional but been populated)
        if model.dependentLocality.present?
          "#{h(model.houseNumber)} #{h(model.streetLine1)}<br />#{h(model.streetLine2)}<br />#{h(model.dependentLocality)}<br />#{h(model.townCity)}<br />#{h(model.postcode)}".html_safe
        else
          "#{h(model.houseNumber)} #{h(model.streetLine1)}<br />#{h(model.streetLine2)}<br />#{h(model.townCity)}<br />#{h(model.postcode)}".html_safe
        end
      else
        # Print UK Address
        if model.dependentLocality.present?
          "#{h(model.houseNumber)} #{h(model.streetLine1)}<br />#{h(model.dependentLocality)}<br />#{h(model.townCity)}<br />#{h(model.postcode)}".html_safe
        else
          "#{h(model.houseNumber)} #{h(model.streetLine1)}<br />#{h(model.townCity)}<br />#{h(model.postcode)}".html_safe
        end
      end
    end
  end

  def format_email(emailIn)
    emailIn.downcase
  end

  def one_full_message_per_invalid_attribute registration
    hash_without_base = registration.errors.messages.except :base

    hash_without_base.each_key do |key|
      singleton_array_of_first_element = Array.wrap(registration.errors.get(key).first)
      registration.errors.set key, singleton_array_of_first_element
    end

    registration.errors.full_messages
  end


  def one_full_message_with_key_per_invalid_attribute registration
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


  # TODO not sure what this should do now smart answers and lower tier have been merged
  def first_back_link registration
    path = if registration.metaData.first.route == 'DIGITAL'
      if user_signed_in?
        userRegistrations_path current_user.id
      else
        find_path
      end
    else
      registrations_path
    end

    link_to t('registrations.form.back_button_label'), path, class: 'button-secondary'
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

  # This method is called when updating from the registration's 'editing' pages (i.e. PUT/POST/MATCH)
  # to set up the @registration etc.
  def setup_registration(current_step, no_update = false)
    logger.info 'setup_registration: current_step = ' + current_step.to_s

    if !session[:editing] && current_step != 'payment' && current_step != 'confirmation'
      logger.info 'Registration is not editable anymore. Cannot access page - current_step = ' + current_step.to_s
      redirect_to cannot_edit_path and return
    end
    
    if session[:registration_id]
      @registration = Registration[session[:registration_id]]
      logger.debug "Got Registration from session"
      @registration.update(current_step: current_step)
    else
      logger.info 'Cannot find registration_id from session, try params[:id]: ' + params[:id].to_s
      @registration = Registration[params[:id]]
      if @registration.nil? and params[:id]
        # Registration still not found in session, trying database
        logger.info 'Cannot find registration in session, trying database'
        @registration = Registration.find_by_id(params[:id])
      end
    end
    
    if @registration
      @registration.add( params[:registration] ) unless no_update

      # Force contact email to lower case
      if @registration.contactEmail
        @registration.contactEmail = format_email(@registration.contactEmail)
      end

      # now check if we're on the address lookup page and -if yes- set
      # the relevant model attribute
      if params[:registration] &&
              params[:registration].keys.size == 2 &&
              (params[:registration].keys[0].eql? "companyName") &&
              (params[:registration].keys[1].eql? "postcode")
        @registration.update(address_lookup_page: 'yes')
      elsif params[:registration] &&
              params[:registration].keys.size == 3 &&
              (params[:registration].keys[0].eql? "company_no") &&
              (params[:registration].keys[1].eql? "companyName") &&
              (params[:registration].keys[2].eql? "postcode")
        @registration.update(address_lookup_page: 'yes')
      end
      
      @registration.save
      @registration.current_step = current_step

      # Additionally set these if route has not gone through registration process
      # this could happen, for instance, if the user's adding copycards to an existing
      # registration
      session[:registration_id] ||= @registration.id
      session[:registration_uuid] ||= @registration.uuid
    else
      logger.warn {'There is no @registration. Redirecting to the Cookies page'}
      redirect_to cookies_path
      return
    end
  end

  # Note: This method is called at the beginning of the GET request handlers for the registration's 'editing' page
  # to set up the @registration etc.
  def new_step_action current_step
    logger.debug "-----------  #{session[:edit_mode]}"
    if (current_step.eql? Registration::FIRST_STEP) && !session[:edit_mode]
      logger.info 'First registration step and not in edit mode - creating new registration...'
      clear_edit_session
      clear_registration_session
      @registration = Registration.create
      session[:registration_id]= @registration.id
      session[:editing] = true
      logger.debug "creating new registration #{@registration.id}"
      m = Metadata.create

      if agency_user_signed_in?
        m.update :route => 'ASSISTED_DIGITAL'
        if @registration.accessCode.blank?
          @registration.update :accessCode => @registration.generate_random_access_code
        end
      else
        m.update :route => 'DIGITAL'
      end

      @registration.metaData.add m

    elsif (current_step.eql? 'businesstype') && !session[:edit_mode] && !session[:registration_id]
      logger.info 'Current step is businesstype, and not in edit mode, and no registration_id in the session. Creating new registration...'
      clear_edit_session
      clear_registration_session
      @registration = Registration.create
      session[:registration_id]= @registration.id
      session[:editing] = true
      logger.debug "creating new registration #{@registration.id}"
      m = Metadata.create

      if agency_user_signed_in?
        m.update :route => 'ASSISTED_DIGITAL'
        if @registration.accessCode.blank?
          @registration.update :accessCode => @registration.generate_random_access_code
        end
      else
        m.update :route => 'DIGITAL'
      end

      @registration.metaData.add m

    elsif  session[:edit_mode] #editing existing registration

      if !session[:editing] && current_step != 'payment' && current_step != 'pending' && current_step != 'businesstype'
        logger.info 'Registration is not editable anymore. Cannot access page - current_step = ' + current_step.to_s
        #puts '*** GGG4 new_step_action ' + current_step.to_s
        redirect_to cannot_edit_path and return
      end

      logger.info 'We are in edit mode. Retrieving registration...'
      @registration = Registration[ session[:registration_id]]
      if @registration
        logger.debug "retrieving registration for edit #{@registration.id}"
      else
        logger.warn 'Could not find registration for id = ' + session[:registration_id].to_s
      end
    else #creating new registration but not first step
      logger.info 'We are somewhere else in creating a registration but not in the first step. Retrieving registration...'
      #puts '*** GGG6 - ' + current_step
      clear_edit_session
      @registration = Registration[ session[:registration_id]]
      if @registration
        logger.debug "retrieving registration #{@registration.id}"
        m = Metadata.create
      else
        logger.warn 'Could not find registration for id = ' + session[:registration_id].to_s
      end

      if !session[:editing] && current_step != 'payment' && current_step != 'pending'
        logger.info 'Registration is not editable anymore. Cannot access page - current_step = ' + current_step.to_s
        #puts '*** GGG5 new_step_action ' + current_step.to_s
        redirect_to cannot_edit_path
        return
      end
    end

    if !@registration
      logger.warn 'new_step_action - no @registration - showing 404 not found'
      renderNotFound
      return
    end

    debug_view_registration("#{ __method__}")
    # TODO by setting the step here this should work better with forward and back buttons and urls
    # but this might have changed the behaviour
    @registration.current_step = current_step

    # Quick fix to get around problem when coming from sign in page and sign_up_mode is still set to sign_in causing
    # some validations to not fire correctly - must be a better place to put this?
    if @registration.current_step == 'signup'
      @registration.sign_up_mode = 'sign_up'
    elsif @registration.current_step == 'signin'
      @registration.sign_up_mode = 'sign_in'
    end

    @registration.save
    logger.debug "new step action: #{current_step}"
    logger.debug "current step: #{ @registration.current_step}"
    # Pass in current page to check previous page is valid
    # TODO had to comment this out for now because causing problems but will probably need to reinstate
    # check_steps_are_valid_up_until_current current_step

    #    if (session[:registration_id])
    #      #TODO show better page - the user should not be able to return to these pages after the registration has been saved
    #      renderNotFound
    #    end
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

  def clear_order_session
    session.delete(:renderType)
    session.delete(:orderId)
    session.delete(:orderCode)
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

    # These must match the css classes they related to
    #criminally_suspect_class = 'criminallySuspect'
    #almost_complete_class = 'almostComplete'
    #complete_class = 'complete'
    #complete_lower_class = 'complete lower'

    if @registration.tier.downcase.eql? 'upper'
      awaiting_conviction_confirm = @registration.is_awaiting_conviction_confirmation?

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
      if awaiting_conviction_confirm && @registration.paid_in_full?
        confirmationType = STATUS_CRIMINALLY_SUSPECT
      elsif !@registration.paid_in_full?
        confirmationType = STATUS_ALMOST_COMPLETE
      else
        confirmationType = STATUS_COMPLETE
      end
    else # lower registration
      confirmationType = STATUS_COMPLETE_LOWER if @registration.get_status.eql? 'ACTIVE'
    end

    unless confirmationType
      logger.debug "REGISTRATIONS_HELPER::GETCONFIRMATIONTYPE For Registration: #{@registration.uuid}"
      logger.debug "REGISTRATIONS_HELPER::GETCONFIRMATIONTYPE awaiting conv confirm: #{awaiting_conviction_confirm}"
      logger.debug "REGISTRATIONS_HELPER::GETCONFIRMATIONTYPE paid_in_full?: #{@registration.paid_in_full?}"
      logger.debug "REGISTRATIONS_HELPER::GETCONFIRMATIONTYPE tier: #{@registration.tier.downcase}"
      logger.debug "REGISTRATIONS_HELPER::GETCONFIRMATIONTYPE status: #{@registration.metaData.first.status.downcase}"
    end

    return confirmationType
  end

  # Sets a flag in the session indicating how the user wants to pay (bank transfer or credit card), or clears
  # the flag if this is currently unknown.  Only used by Google Analytics.
  def set_google_analytics_payment_indicator(session, order)
    session.delete(:ga_payment_method)
    if order
      if order.isOnlinePayment?
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

  def isCurrentRegistrationType registrationNumber
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
      {controller: 'key_people', action: 'newKeyPeople'}
    else
      {action: 'newConfirmation'}
    end

  end

  def debug_view_registration( caller )
    if @registration
      logger.debug "Method: #{caller} - Registration: #{@registration.id}  #{@registration.to_json}"
    else
      logger.debug "Method: #{caller} - Registration is nil"
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
    redirect_to :newBusinessDetails
  end

end
