module RegistrationsHelper

  def validation_for(model, attribute)
    if model.errors[attribute].any?
      # Note: Calling raw() forces the characters to be un-escaped and thus HTML elements can be defined here
      raw("<span class=\"error-text\">#{model.errors.full_messages_for(attribute).first}</span>")
    else
      ""
    end
  end

  def format_date(string)
    d = string.to_date
    d.strftime('%A ' + d.mday.ordinalize + ' %B %Y')
  end

  def format_address(model)
    if model.postcode.nil?
      # Print International address
      "#{h(model.streetLine1)}<br />#{h(model.streetLine2)}<br />#{h(model.streetLine3)}<br />#{h(model.streetLine4)}<br />#{h(model.country)}".html_safe
    else
      if model.streetLine2.present?
        # Print UK Address Including Street line 2 (as its optional but been populated)
        "#{h(model.houseNumber)} #{h(model.streetLine1)}<br />#{h(model.streetLine2)}<br />#{h(model.townCity)}<br />#{h(model.postcode)}".html_safe
      else
        # Print UK Address
        "#{h(model.houseNumber)} #{h(model.streetLine1)}<br />#{h(model.townCity)}<br />#{h(model.postcode)}".html_safe
      end
    end
  end

  def one_full_message_per_invalid_attribute registration
    hash_without_base = registration.errors.messages.except :base

    hash_without_base.each_key do |key|
      singleton_array_of_first_element = Array.wrap(registration.errors.get(key).first)
      registration.errors.set key, singleton_array_of_first_element
    end

    registration.errors.full_messages
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

  def setup_registration current_step, no_update=false
    if session[:registration_id]
      @registration = Registration[ session[:registration_id]]
      logger.debug "Got Registration from session"
    else
      Rails.logger.info 'Cannot find registration_id from session, try params[:id]: ' + params[:id].to_s
      @registration = Registration[ params[:id]]
      if @registration.nil? and params[:id]
        # Registration still not found in session, trying database
        Rails.logger.info 'Cannot find registration in session, trying database'
        @registration = Registration.find_by_id(params[:id])
      end
    end
    if @registration
      @registration.add( params[:registration] ) unless no_update
      @registration.save
      logger.debug "Registration: id=#{@registration.id.to_s} #{@registration.attributes.to_s}"
      @registration.current_step = current_step

      # Additionally set these if route has not gone through registration process
      # this could happen, for instance, if the user's adding copycards to an existing
      # registration
      session[:registration_id] ||= @registration.id
      session[:registration_uuid] ||= @registration.uuid
    else
      logger.warn 'There is no @registration'
      redirect_to cookies_path
      return
    end
  end

  def new_step_action current_step
    logger.debug "-----------  #{session[:edit_mode]}"
    if (current_step.eql? Registration::FIRST_STEP) && !session[:edit_mode]
      clear_edit_session
      clear_registration_session
      @registration = Registration.create
      session[:registration_id]= @registration.id
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
      clear_edit_session
      clear_registration_session
      @registration = Registration.create
      session[:registration_id]= @registration.id
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
      @registration = Registration[ session[:registration_id]]
      if @registration
        logger.debug "retrieving registration for edit #{@registration.id}"
      end
    else #creating new registration but not first step
      clear_edit_session
      @registration = Registration[ session[:registration_id]]
      if @registration
        logger.debug "retrieving registration #{@registration.id}"
        m = Metadata.create
      end
    end

    if !@registration
      renderNotFound
      return
    end

    debug_print_registration("#{ __method__}")
    # TODO by setting the step here this should work better with forward and back buttons and urls
    # but this might have changed the behaviour
    @registration.current_step = current_step
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
    logger.debug "#{ __method__}"
  end

  def clear_registration_session
    # Clear session variables
    session.delete(:registration_id)
    session.delete(:registration_uuid)

    #clear/reset session variables used for Google Analytics
    session.delete(:ga_is_renewal)
    session.delete(:ga_tier)
    session.delete(:ga_status)
  end
  
  def clear_order_session
    session.delete(:renderType)
    session.delete(:orderCode)
  end

  def give_meaning_to_reg_type(attr_value)
    case attr_value
    when 'carrier_broker_dealer'
      "carrier broker and dealer"
    when 'carrier_dealer'
      "carrier dealer (you carry the waste yourselves)"
    when 'broker_dealer'
      "broker dealer (you arrange for other people to carry the waste)"
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

      if awaiting_conviction_confirm
        confirmationType = STATUS_CRIMINALLY_SUSPECT
      elsif !@registration.paid_in_full? && !awaiting_conviction_confirm
        confirmationType = STATUS_ALMOST_COMPLETE
      else
        # session[:edit_result].to_i ==  EditResult::CREATE_NEW_REGISTRATION
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

    confirmationType
  end

  #return the status color indicator for Google Analytics: 'green' or 'amber' depending on registration confirmation status
  def google_analytics_status_color confirmation_type
    logger.info 'Determine Google Analytics status color to show for confirmation type: ' + confirmation_type.to_s
    ga_color = ''
    if !confirmation_type
      return ga_color
    end

    if confirmation_type.eql? STATUS_COMPLETE
      ga_color = 'green'
    elsif confirmation_type.eql? STATUS_COMPLETE_LOWER
      ga_color = 'green'
    elsif confirmation_type.eql? STATUS_ALMOST_COMPLETE 
      ga_color = 'amber'
    elsif confirmation_type.eql? STATUS_CRIMINALLY_SUSPECT
      ga_color = 'amber'
    end
    ga_color
  end

  #return 'bacs' for bank transfer, or 'cc' for card payments, or an empty string if not yet determined
  def google_analytics_payment_indicator current_order
    payment_indicator = ''
    if !current_order
      return payment_indicator
    end
    if current_order.isOnlinePayment?
      payment_indicator = 'cc'
    elsif current_order.isOfflinePayment?
      payment_indicator = 'bacs'
    end
    payment_indicator
  end

  #Return true or false based on the user's andwer to the has-relevant-convictions question
  def google_analytics_convictions_indicator registration
    if !registration
      return ''
    end
    if registration.declaredConvictions == 'yes'
      return 'true'
    elsif registration.declaredConvictions == 'no'
      return 'false'
    end
    ''
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

  def isIRRegistrationType registrationNumber
    if registrationNumber
      # Strip leading and trailing whitespace from number
      regNo = registrationNumber.rstrip.lstrip

      # Just look at first 3 characters
      regNo = regNo[0, 3]

      # First 3 characters of reg ex
      legacy_reg_format = "CB/"

      # Check legacy format
      res = regNo.upcase.match(legacy_reg_format)
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

  def create_new_reg
    res = true
    logger.debug session[:edit_mode]
    logger.debug session[:edit_result]
    if  session[:edit_result].to_i ==  RegistrationsController::EditResult::CREATE_NEW_REGISTRATION
      if  session[:edit_mode].to_i == RegistrationsController::EditMode::RECREATE
        original_registration = Registration[ session[:original_registration_id] ]
        original_registration.metaData.first.update(status: 'DELETED')
        res = original_registration.save!
      end
      res = @registration.commit if res
    end
    res
  end

  def debug_print_registration( caller )
    if @registration
      logger.debug "Method: #{caller} - Registration: #{@registration.id}  #{@registration.to_json}"
    else
      logger.debug "Method: #{caller} - Registration is nil"
    end
  end

end
