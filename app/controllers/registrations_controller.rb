class RegistrationsController < ApplicationController

  include WorldpayHelper
  include RegistrationsHelper

  module Status
    REVOKED = -2
    EXPIRED = -1
    PENDING = 0
    ACTIVE = 1
  end

  module EditResult
    START = -999
    NO_CHANGES = 1
    UPDATE_EXISTING_REGISTRATION_NO_CHARGE = 2
    UPDATE_EXISTING_REGISTRATION_WITH_CHARGE = 3
    CREATE_NEW_REGISTRATION = 4
    CHANGE_NOT_ALLOWED = 5
  end

  module EditMode
    EDIT = 1
    RENEWAL = 2
    RECREATE= 3
  end


  #We require authentication (and authorisation) largely only for editing registrations,
  #and for viewing the finished/completed registration.

  before_filter :authenticate_admin_request!

  before_filter :authenticate_external_user!, :only => [:update, :destroy, :finish, :print]

  # GET /registrations
  # GET /registrations.json
  def index
    authenticate_agency_user!
    searchWithin = params[:searchWithin]
    searchString = params[:q]
    if validate_search_parameters?(searchString,searchWithin)
      @registrations = []
      unless searchString.blank?
        @registrations = Registration.find_all_by(searchString, searchWithin)
      end
    else
      @registrations = []
      flash.now[:notice] = I18n.t('errors.messages.search_criteria')
    end
    session[:registration_step] = session[:registration_params] = nil
    logger.debug "index: #{ @registrations.size.to_s} items"

    #
    # REVIEWME: Ideally this should not be needed but in order to cover the 'Back and refresh issue'
    # The variables will be cleared for subequent requests
    # This will not fix a user clicking and Edit then using browser back, and then clicking a link
    # that was present, e.g click an edit, go back then click New registration.
    #
    clear_edit_session
    clear_registration_session
    clear_order_session
    logger.debug "Cleared registration session variables"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrations }
    end
  end

  # GET /your-registration/business-details
  def newBusinessDetails
    new_step_action 'businessdetails'

    if !@registration
      logger.warn 'There is no @registration - cannot proceed with address details'
      return
    end

    if params[:changeAddress]
      @registration.addressMode = nil
    end

    if params[:manualUkAddress] #we're in the manual uk address page
      @registration.addressMode = 'manual-uk'
      #clear any existing address fields, in case we changed over from foreign address
      @registration.streetLine3 = @registration.streetLine4 = @registration.country = nil
    elsif params[:foreignAddress] #we're in the manual foreign address page
      @registration.addressMode = 'manual-foreign'
      #clear any existing address fields, in case we changed over from uk address
      @registration.streetLine1 = @registration.streetLine2 = @registration.townCity = @registration.postcode = nil
    elsif params[:autoUkAddress] #user clicked to go back to address lookup
      @registration.addressMode = nil
    end

    @registration.save

    #Load the list of addresses from the address lookup service if the user previously has clicked on the 'Find Address' button
    if 'address-results'.eql? @registration.addressMode
      begin
        @address_match_list = Address.find(:all, :params => {:postcode => @registration.postcode})
        session.delete(:address_lookup_failure) if session[:address_lookup_failure]
        logger.debug "Address lookup found #{@address_match_list.size.to_s} addresses"
        logger.debug "@registration.postcode: '#{!@registration.postcode.empty?}'"
        if @address_match_list.size < 1 && !@registration.postcode.empty?
          @registration.errors.add(:postcode, ' test')
        end
      rescue Errno::ECONNREFUSED
        session[:address_lookup_failure] = true
        logger.error 'ERROR: Address Lookup Not running, or not found'
      rescue ActiveResource::ServerError
        session[:address_lookup_failure] = true
        logger.error 'ERROR: ActiveResource Server error!'
      rescue ActiveResource::BadRequest
        logger.warn 'Address lookup returned Bad Request error code - postcode valid? - ' + @registration.postcode.to_s
        @address_match_list = []
      end
    end

  end

  # GET /your-registration/edit/business-details
  def editBusinessDetails
    session[:edit_link_business_details] = '1'
    new_step_action 'businessdetails'

    if params[:changeAddress]
      @registration.addressMode = nil
    elsif params[:manualUkAddress] #we're in the manual uk address page
      @registration.addressMode = 'manual-uk'
      #clear any existing address fields, in case we changed over from foreign address
      @registration.streetLine3 = @registration.streetLine4 = @registration.country = nil
    elsif params[:foreignAddress] #we're in the manual foreign address page
      @registration.addressMode = 'manual-foreign'
      #clear any existing address fields, in case we changed over from uk address
      @registration.streetLine1 = @registration.streetLine2 = @registration.townCity = @registration.postcode = nil
    elsif params[:autoUkAddress] #user clicked to go back to address lookup
      @registration.addressMode = nil
    end

    @registration.save

    #Load the list of addresses from the address lookup service if the user previously has clicked on the 'Find Address' button
    if 'address-results'.eql? @registration.addressMode
      begin
        logger.info "addressMode is 'address-results'. Reading match list again..."
        @address_match_list = Address.find(:all, :params => {:postcode => @registration.postcode})
        session.delete(:address_lookup_failure) if session[:address_lookup_failure]
        logger.debug "Address lookup found #{@address_match_list.size.to_s} addresses"
        logger.debug "@registration.postcode: '#{!@registration.postcode.empty?}'"
        if @address_match_list.size < 1 && !@registration.postcode.empty?
          @registration.errors.add(:postcode, ' test')
        end
      rescue Errno::ECONNREFUSED
        session[:address_lookup_failure] = true
        logger.error 'ERROR: Address Lookup Not running, or not Found'
      rescue ActiveResource::ServerError
        session[:address_lookup_failure] = true
        logger.error 'ERROR: ActiveResource Server error!'
      end
    end

    render 'newBusinessDetails'
  end

  # POST /your-registration/business-details
  def updateNewBusinessDetails
    setup_registration 'businessdetails'
    return unless @registration

    logger.info 'Entering updateNewBusinessDetails - the @registration has been set up...'

    session.delete(:address_lookup_selected) if session[:address_lookup_selected]

    #if params[:addressSelector]  #user selected an address from drop-down list
    #if @registration.selectedAddress and !@registration.selectedAddress.empty?
    if params[:registration][:selectedAddress]
      logger.info '>>>>>>>> validate selected address'
      @registration.validateSelectedAddress = true
    end

    if @registration.selectedAddress and !@registration.selectedAddress.empty?

      logger.info '>>>>>>>> @registration.selectedAddress has a value'

      fullVal = @registration.selectedAddress

      logger.info 'fullVal: ' + fullVal.to_s

      array = fullVal.split('::')
      logger.error 'array: ' + array.to_s
      logger.error 'array[0]: ' + array[0].to_s
      moniker = array[0].to_s
      logger.error 'array[1]: ' + array[1].to_s
      @registration.selectedAddress = array[1].to_s
      logger.error '@registration.selectedAddress: ' +  @registration.selectedAddress

      logger.info 'Retrieving address for the selected moniker: ' + moniker.to_s
      @selected_address = Address.find(moniker)
      logger.info 'Retrieved @selected_address = ' + @selected_address.inspect.to_s
      session[:address_lookup_selected] = true
      @selected_address ? copyAddressToSession :  logger.error("Couldn't match address #{params[:addressSelector]}")

    end

    if params[:findAddress] #user clicked on Find Address button
      logger.info '>>>>>>>> in findAddress'
      if @registration.valid?
        # clicked find and valid
        @registration.update(:addressMode => 'address-results')
        @registration.update(:postcode => params[:registration][:postcode])

        redirect_to :newBusinessDetails and return
      else
        # clicked find and not valid
        render 'newBusinessDetails', status: '200' and return
      end

#      if @registration.postcode.empty?
#        @registration.errors.add(:postcode, ' test1')
#
#        render 'newBusinessDetails', status: '200' and return
#      else
#
#      #GGG - this bit should be done on the subsequent GET
#      #render 'newBusinessDetails', status: '200'
#      redirect_to :newBusinessDetails and return
#      end
    elsif @registration.valid?

      logger.info '>>>>>>>> elsif valid'

      if @registration.tier.eql? 'UPPER'
        @registration.cross_check_convictions
        @registration.save
      end

      if session[:edit_link_business_details]
        session.delete(:edit_link_business_details)
        redirect_to :newConfirmation and return
        #if session[:edit_mode]
        #  case @registration.businessType
        #  when  'partnership', 'limitedCompany', 'publicBody'
        #    redirect_to :newKeyPerson and return
        #  else
        #    redirect_to :newConfirmation and return
        #  end
      else
        redirect_to :newContact and return
      end
    else

    logger.error '>>>>>>>> if not valid'

    #Load the list of addresses from the address lookup service if the user previously has clicked on the 'Find Address' button
    if 'address-results'.eql? @registration.addressMode
      logger.info 'We are in the address-results mode. About to retrieve the address match list (again)...'
      begin
        @address_match_list = Address.find(:all, :params => {:postcode => @registration.postcode})
        session.delete(:address_lookup_failure) if session[:address_lookup_failure]
        logger.debug "Address lookup found #{@address_match_list.size.to_s} addresses"
        if @address_match_list.size < 1 && !@registration.postcode.empty?
          @registration.errors.add(:postcode, ' test')
        end
      rescue Errno::ECONNREFUSED
        session[:address_lookup_failure] = true
        logger.error 'ERROR: Address Lookup not running, or not found'
      rescue ActiveResource::ServerError
        session[:address_lookup_failure] = true
        logger.error 'ERROR: ActiveResource Server error!'
      end
    end

      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render 'newBusinessDetails', :status => '400'
    end
  end

  # GET /your-registration/contact-details
  def newContactDetails
    new_step_action 'contactdetails'
  end

  # GET /your-registration/edit/contact-details
  def editContactDetails
    session[:edit_link_contact_details] = '1'
    new_step_action 'contactdetails'
    render 'newContactDetails'
  end

  # POST /your-registration/contact-details
  def updateNewContactDetails
    setup_registration 'contactdetails'
    return unless @registration

    # TODO Check why this is here with Fred. Was in Upper Tier
    # version of update contact details but don't see how you
    # get to this post and need to check for findAddress
    # if params[:findAddress]
    #   render "newBusinessDetails" and return
    # end



    if @registration.valid?
      if session[:edit_link_contact_details]
        session.delete(:edit_link_contact_details)
        redirect_to :newConfirmation and return
      end
      if @registration.tier.eql? 'LOWER'
        redirect_to :newConfirmation and return
      else
        redirect_to :registration_key_people and return
      end

    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render 'newContactDetails', :status => '400'
    end
  end

  # GET /your-registration/registration-type
  def newRegistrationType
    new_step_action 'registrationtype'
  end

  # GET /your-registration/edit/registration-type
  def editRegistrationType
    session[:edit_link_reg_type] = '1'
    new_step_action 'registrationtype'
    render 'newRegistrationType'
  end

  # POST /your-registration/registration-type
  def updateNewRegistrationType
    setup_registration 'registrationtype'
    return unless @registration

    if @registration.valid?
      if session[:edit_link_reg_type]
        #if session[:edit_mode]
        session.delete(:edit_link_reg_type)
        redirect_to :newConfirmation and return
      else
        redirect_to :newBusinessDetails  and return
      end
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render 'newRegistrationType', :status => '400'
    end
  end

  def newRelevantConvictions
    new_step_action 'convictions'
  end

  def updateNewRelevantConvictions
    setup_registration 'convictions'
    return unless @registration

    if @registration.valid?
      #      (redirect_to :newConfirmation and return) if session[:edit_mode]
      if @registration.declaredConvictions == 'yes'
        redirect_to :newRelevantPeople
      else
        redirect_to :newConfirmation
      end
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newRelevantConvictions", :status => '400'
    end
  end

  # GET /your-registration/confirmation
  def newConfirmation
    new_step_action 'confirmation'
    if !@registration
      return
    end
    case session[:edit_mode].to_i
    when EditMode::RECREATE
      @registration.declaration = false
    when EditMode::EDIT, EditMode::RENEWAL
      @registration.declaration = false
      if session[:edit_result].to_i.eql? EditResult::START  #this is the first time we hit the confirmation page
        session[:edit_result] = EditResult::START + 1
      else #we've hit the confirmation page before
        logger.debug "going to compare"
        original_registration = Registration[ session[:original_registration_id] ]
        session[:edit_result] =  compare_registrations(@registration, original_registration )
      end

      # update_registration session[:edit_mode]
    else # new registration, do nothing (default rendering will occur)

      # Check if IR Renewal
      logger.debug "Check if IR renewal flow"
      if @registration.originalRegistrationNumber and isIRRegistrationType(@registration.originalRegistrationNumber) and @registration.newOrRenew
        logger.debug "IR renewal flow found"
        original_registration = Registration[ session[:original_registration_id] ]
        session[:edit_result] =  compare_registrations(@registration, original_registration )
        logger.debug "edit result: " + session[:edit_result].to_s

        case session[:edit_result].to_i
        when RegistrationsController::EditResult::UPDATE_EXISTING_REGISTRATION_NO_CHARGE
          logger.debug "++++++++++++++++++++++++ ir data, no charge"
        when RegistrationsController::EditResult::UPDATE_EXISTING_REGISTRATION_WITH_CHARGE
          logger.debug "++++++++++++++++++++++++ charge"
        when RegistrationsController::EditResult::CREATE_NEW_REGISTRATION
          logger.debug "++++++++++++++++++++++++ ir data changed to new reg"
        when RegistrationsController::EditResult::NO_CHANGES
          logger.debug "++++++++++++++++++++++++ no change"
        end #case

        # Set edit mode to renew, to show panel for renew
        session[:edit_mode] = RegistrationsController::EditMode::RENEWAL

      end

    end #case

    logger.debug "edit_mode = #{ session[:edit_mode]}"
    logger.debug "edit_result = #{ session[:edit_result]}"
  end

  # POST /your-registration/confirmation
  def updateNewConfirmation
    setup_registration 'confirmation'
    return unless @registration

    logger.debug "edit_mode = #{ session[:edit_mode]}"
    logger.debug "edit_result = #{ session[:edit_result]}"

    if @registration.valid?
      case session[:edit_mode].to_i
      when EditMode::RECREATE
        redirect_to upper_payment_path(@registration.uuid) and return
      when EditMode::EDIT
        case session[:edit_result].to_i
        # Check if no Immediate edit actions have occured, and redirect back to appropraite start point
        # This assumes that because the edit_result orignally is set to the start, and then when newConfirmation is
        # rendered it is incremented by one, that this is the only situation where that can occur.
        when  EditResult::START + 1
          clear_edit_session # we don't need edit variables polluting the session any more
          if current_user
            redirect_to userRegistrations_path(current_user)
          elsif current_agency_user
            redirect_to :action => 'index'
          else
            renderAccessDenied
          end
        when  EditResult::NO_CHANGES, EditResult::UPDATE_EXISTING_REGISTRATION_NO_CHARGE
          if @registration.save!
            logger.debug "Registration #{@registration.uuid} now saved!"
          else
            #TODO: error handling
          end #if
          edit_mode = session[:edit_mode]
          edit_result = session[:edit_result]
          clear_edit_session # we don't need edit variables polluting the session any more
          # redirect_to(action: 'editRenewComplete', edit_mode: edit_mode, edit_result: edit_result) and return
          redirect_to complete_edit_renew_path(id: @registration.uuid, edit_mode: edit_mode, edit_result: edit_result) and return
        when  EditResult::UPDATE_EXISTING_REGISTRATION_WITH_CHARGE
          newOrderEdit @registration.uuid
        when  EditResult::CREATE_NEW_REGISTRATION
          # If a new registration is needed at this point it should be created as the payment will they be processed aggainst that registration and
          # not the original one, which should be marked as deleted

          #
          # TODO::
          # :Make a copy of the registration in memory (create a new local)
          newRegistration = Registration.create
          session[:editing] = true

          logger.info 'before: ' + newRegistration.to_json
          logger.info 'before: ' + newRegistration.attributes.to_s

          newRegistration.add( @registration.to_hash )
          newRegistration.add( @registration.attributes )

          logger.info ''
          logger.info '================='
          logger.info '==== NEW REGISTRAION ============='
          logger.info 'after: ' + newRegistration.to_json.to_s
          logger.info 'after: ' + newRegistration.attributes.to_s
          logger.info '================='
          logger.info ''

          # Need to re-get registration from DB as we are leaving the original alone
          originalRegistration = Registration.find_by_id(@registration.uuid)
          # :Mark original registration as deleted and save to db
          originalRegistration.metaData.first.update(:status=>'INACTIVE')
          logger.info 'updated meta data, about to save to db'

          if originalRegistration.save!
            logger.info 'saved to db now update redis: ' + @registration.id
            originalRegistration.save
          end


          # :Use copy of registration in memory and save to database
          logger.info 'Check if newRegistraiton is valid'
          newRegistration.current_step = 'confirmation'
          if newRegistration.valid?
            newRegistration.reg_uuid = SecureRandom.uuid
            if newRegistration.commit
              newRegistration.save
              @registration = newRegistration
              session[:registration_id] = newRegistration.id
              session[:registration_uuid] = @registration.uuid
            else
              logger.info 'newRegistration failed to commit'
              # return to new Confirmation
              redirect_to :newConfirmation and return
            end
          else
            logger.info 'newRegistration not valid.'
            # return to new Confirmation
            redirect_to :newConfirmation and return
          end

          # :Save copied registration to redis and update any session variables
          @registration.save
          logger.info 'new reg saved to db now save to redis: ' + @registration.id

          #
          #logger.info 'Registration is not valid, and data is not yet saved'
          #render "newConfirmation", :status => '400'

          #redirect_to newOrderCausedNew_path(@registration.uuid) and return
          logger.info '@registration.uuid:' + @registration.uuid
          newOrderCausedNew @registration.uuid
          #newOrderEdit @registration.uuid
        else
          edit_mode = session[:edit_mode]
          edit_result = session[:edit_result]
          clear_edit_session # we don't need edit variables polluting the session any more
          redirect_to(action: 'editRenewComplete', edit_mode: edit_mode, edit_result: edit_result) and return
        end

      when EditMode::RENEWAL

        # Detect standard or IR renewal
        if @registration.originalRegistrationNumber and isIRRegistrationType(@registration.originalRegistrationNumber) and @registration.newOrRenew

          logger.debug "Is IR RENEWAL"

          # ir renewal detected
          redirect_to :action => :account_mode
        else

          logger.debug "Is normal RENEWAL"

          # not needed as expiry date set in the services when payment is reveived for the renewal
          #@registration.expires_on = (Time.parse(@registration.expires_on) + Rails.configuration.registration_expires_after).to_s

          @registration.renewalRequested = true;

          @registration.save
          newOrderRenew(@registration.uuid) and return
        end
      else # new registration
        redirect_to :action => :account_mode
      end #case

    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newConfirmation", :status => '400'
    end
  end

  # GET /your-registration/account-mode
  def account_mode
    new_step_action 'account-mode'

    user_signed_in = false
    agency_user_signed_in = false

    if user_signed_in?
      @registration.accountEmail = current_user.email
      @user = User.find_by_email(@registration.accountEmail)
      user_signed_in = true
    elsif agency_user_signed_in?
      @registration.accountEmail = current_agency_user.email
      @user = User.find_by_email(@registration.accountEmail)
      agency_user_signed_in = true
    else
      @registration.accountEmail = @registration.contactEmail
    end

    # Get signup mode
    account_mode_val = @registration.initialize_sign_up_mode(@registration.accountEmail, (user_signed_in || agency_user_signed_in))

    @registration.sign_up_mode = account_mode_val
    logger.debug "Account mode is #{account_mode_val} and sign_up_mode is #{@registration.sign_up_mode}"
    @registration.save

    case account_mode_val
    when 'sign_in'
      redirect_to :action => 'newSignin'
    when 'sign_up'
      redirect_to :action => 'newSignup'
    else
      if @registration.valid?
        case @registration.tier
        when 'LOWER'
          if complete_new_registration(true)
            logger.debug "Registration created, about to check user type"
            if user_signed_in
              redirect_to :action => 'finish'
            else
              redirect_to :action => 'finishAssisted'
            end
          else
            @registration.errors.add(:exception, "Unable to commit registration")
            render "newConfirmation", :status => '400'
          end
        when 'UPPER'
          complete_new_registration
          #
          # Important!
          # Now storing an additional variable in the session for the type of order
          # you are about to make.
          # This session variable needs to be set every time the order/new action
          # is requested.
          #
          newOrder @registration.uuid
        end
      else
        render "newConfirmation", :status => '400'
      end
    end

  end

  # GET /your-registration/signin
  def newSignin
    new_step_action 'signin'
  end

  # POST /your-registration/signin
  def updateNewSignin
    setup_registration 'signin'
    return unless @registration

    unless user_signed_in?
      @user = User.find_by_email(@registration.accountEmail)
      if @registration.valid?
        sign_in @user
      else
        logger.error "GGG ERROR - password not valid for user with e-mail = " + @registration.accountEmail
        render "newSignin", :status => '400'
        return
      end
    end

    if !@registration.valid?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newSignin", :status => '400'
      return
    end

    case @registration.tier
    when 'LOWER'
      complete_new_registration true
    when 'UPPER'
      complete_new_registration
    end

    @registration.sign_up_mode = ''
    @registration.save

    case @registration.tier
    when 'LOWER'
      redirect_to :action => 'finish'
    when 'UPPER'
      #
      # Important!
      # Now storing an additional variable in the session for the type of order
      # you are about to make.
      # This session variable needs to be set every time the order/new action
      # is requested.
      #

      # Determine what type of registration order to create
      # If an originalRegistrationNumber is presenet in the registration, then the registraiton is an IR Renewal
      if @registration.originalRegistrationNumber and isIRRegistrationType(@registration.originalRegistrationNumber)
        if session[:edit_result]
          case session[:edit_result].to_i
          when  EditResult::NO_CHANGES, EditResult::UPDATE_EXISTING_REGISTRATION_NO_CHARGE, EditResult::UPDATE_EXISTING_REGISTRATION_WITH_CHARGE
            # no charge or ir renewal with charge
            newOrderRenew @registration.uuid
          when  EditResult::CREATE_NEW_REGISTRATION
            # ir renewal converted to new because of changes
            newOrder @registration.uuid
          else
            # standard renewal
            newOrderRenew @registration.uuid
          end
        else
          newOrderRenew @registration.uuid
        end
      else
        newOrder @registration.uuid
      end
    end
  end

  # GET /your-registration/signup
  def newSignup
    new_step_action 'signup'
  end

  # POST /your-registration/signup
  def updateNewSignup
    setup_registration 'signup'
    return unless @registration

    if @registration.valid?
      logger.debug 'The registration is valid...'
      logger.info 'Check to commit registration, unless: ' + @registration.persisted?.to_s
      unless @registration.persisted?
        # Note: we have to store the new user first, and only if that succeeds, we want to commit the registration
        logger.info 'Check to commit user, unless: ' + current_user.to_s
        unless current_user
          if !commit_new_user
            render "newSignup", :status => '400'
            return
          end
        end

        if commit_new_registration?
          logger.info 'The new registration has been committed successfully'
        else #registration was not committed
          # there is an error (but data not yet saved)
          logger.error 'Registration was valid but data is not yet saved due to an error in the services'
          @registration.errors.add(:exception, @registration.exception.to_s)
          render "newSignup", :status => '400'
          return
        end
      end

    else # the registration is not valid
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newSignup", :status => '400'
      return
    end

    logger.debug 'Determining next_step for redirection'

    next_step = case @registration.tier
    when 'LOWER'
      pending_url
    when 'UPPER'
      #
      # Important!
      # Now storing an additional variable in the session for the type of order
      # you are about to make.
      # This session variable needs to be set every time the order/new action
      # is requested.
      #

      # Determine what type of registration order to create
      # If an originalRegistrationNumber is present in the registration, then the registraiton is an IR Renewal
      if @registration.originalRegistrationNumber and isIRRegistrationType(@registration.originalRegistrationNumber)
        session[:renderType] = Order.renew_registration_identifier
        if session[:edit_result]
          if session[:edit_result].to_i.eql? EditResult::CREATE_NEW_REGISTRATION
            session[:renderType] = Order.editrenew_caused_new_identifier
          end
        end
      else
        session[:renderType] = Order.new_registration_identifier
      end

      session[:orderCode] = generateOrderCode
      upper_payment_path(:id => @registration.uuid)
    end

    # Reset Signed up user to signed in status
    @registration.sign_up_mode = 'sign_in'
    @registration.save!

    redirect_to next_step
  end

  # GET /registrations/finish
  def finish
    @registration = Registration.find_by_id(session[:registration_uuid])
    authorize! :read, @registration

    @confirmationType = getConfirmationType
    unless @confirmationType
      flash[:notice] = 'Invalid confirmation type. Check routing to this page'
      renderNotFound and return
    end
  end

  # POST /registrations/finish
  def updateFinish
    if user_signed_in?
      #
      # Finished here, ok to clear session variables
      #
      clear_registration_session
      redirect_to userRegistrations_path(current_user)
    else
      renderNotFound
    end
  end

  # GET /registrations/finish-assisted
  def finishAssisted
    @registration = Registration.find_by_id(session[:registration_uuid])
    authorize! :read, @registration
  end

  # POST /registrations/finish-assisted
  def updateFinishAssisted
    if agency_user_signed_in?
      clear_registration_session
      redirect_to :action => 'index'
    else
      renderNotFound
    end
  end

  # GET /registrations/cannot-edit
  def cannot_edit
  end

  # GET /registrations/data-protection
  def dataProtection
    # Renders static data proctection page
  end

  def commit_new_registration?

    unless @registration.tier == 'LOWER'
      @registration.expires_on = (Date.current + Rails.configuration.registration_expires_after).to_s
    end

    # Note: we are assigning a unique identifier to the registration in order to make the
    # POST request idempotent
    @registration.reg_uuid = SecureRandom.uuid

    @registration.save
    if @registration.commit
      session[:registration_uuid] = @registration.uuid
      session[:registration_id] = @registration.id
      session[:editing] = false
      logger.debug "Registration commited"
      true
    else
      false
    end
  end

  def commit_new_user
    @user = User.new
    @user.email = @registration.accountEmail
    @user.password = @registration.password
    @user.current_tier = @registration.tier
    logger.debug "About to save the new user."
    if @user.save
      logger.debug 'User has been saved.'
      # In the case of new UT registrations we eventually redirect directly to the confirmed page without them
      # first having to have clicked the link in the confirmaton email. The Confirmed action relies on pulling
      # out the user from the session as when you do click the link the ConfirmationsController::after_confirmation_path_for
      # action stores the confirmed user there.
      session[:user] = @user
      return true
    else
      logger.info 'Could not save user. Errors: ' + @user.errors.full_messages.to_s
      @registration.errors.add(:accountEmail, @user.errors.full_messages)
      return false
    end
  end

  def complete_new_registration (activateRegistration=false)

    unless @registration.persisted?

      if commit_new_registration?
        logger.debug "Committed registration, about to activate if appropriate"
        @registration.activate! if activateRegistration
        @registration.save

        unless @registration.assisted_digital?
          if @registration.is_complete?
            RegistrationMailer.welcome_email(@user, @registration).deliver
          end
        end
        true
      else
        false
      end

    end
    true  #Return true as already saved in db, as false is used for failed to save
  end

  def validate_search_parameters?(searchString, searchWithin)
    searchString_valid = searchString == nil || !searchString.empty? && searchString.match(Registration::VALID_CHARACTERS)
    searchWithin_valid = searchWithin == nil || searchWithin.empty? || (['any','companyName','contactName','postcode'].include? searchWithin)
    searchString_valid && searchWithin_valid
  end

  def validate_public_search_parameters?(searchString, searchWithin, searchDistance, searchPostcode)
    searchString_valid = searchString == nil || !searchString.empty? && (!searchString.match(Registration::VALID_CHARACTERS).nil?)
    searchWithin_valid = searchWithin == nil || !searchWithin.empty? && (['any','companyName','contactName','postcode'].include? searchWithin)
    searchDistance_valid = searchDistance == nil || !searchDistance.empty? && (Registration::DISTANCES.include? searchDistance)
    searchPostcode_valid = searchPostcode == nil || searchPostcode.empty? || searchPostcode.match(Registration::POSTCODE_CHARACTERS)

    searchCrossField_valid = true
    # Add cross field check, to ensure that correct params supplied if needed
    if !searchString.nil?
      if !searchString.empty?
        if searchDistance.nil? || searchPostcode.nil?
          searchCrossField_valid = false
        end
      end
    end

    logger.debug 'Validate Public Search Params Q:' + searchString_valid.to_s + ' SW:' + searchWithin_valid.to_s + ' D:' + searchDistance_valid.to_s + ' P:' + searchPostcode_valid.to_s + ' CF: ' + searchCrossField_valid.to_s
    searchString_valid && searchWithin_valid && searchDistance_valid && searchPostcode_valid && searchCrossField_valid
  end

  def userRegistrations
    # Get user from id in url
    tmpUser = User.find_by_id(params[:id])
    # if matches current logged in user
    if tmpUser.nil? || current_user.nil?
      logger.info 'user not found - Showing Session Expired'
      renderSessionExpired
    elsif current_user.email != tmpUser.email
      logger.warn 'User is requesting somebody else\'s registrations? - Showing Access Denied'
      renderAccessDenied
    else
      # Search for users registrations
      @registrations = Registration.find_by_email(tmpUser.email,
                                                  %w(ACTIVE PENDING REVOKED EXPIRED)).sort_by { |r| r.date_registered }

      #TODO GM - editing should start later, this is just a quick fix/hack to get the current logic working
      session[:editing] = true

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @registrations }
      end
    end
  end

  # GET /registrations/1
  # GET /registrations/1.json
  def show
    renderNotFound
  end


  def print

    reg_uuid = params[:id] || session[:registration_uuid]

    renderNotFound and return unless reg_uuid
    @registration = Registration.find_by_id( reg_uuid )
    redirect_to registrations_path and return unless @registration

    authorize! :read, @registration
    if params[:finish]
      if agency_user_signed_in?
        logger.info 'Keep agency user signed in before redirecting back to search page'
        redirect_to registrations_path
      else
        logger.info 'Sign user out before redirecting back to GDS site'
        sign_out        # Performs a signout action on the current user
        redirect_to Rails.configuration.waste_exemplar_end_url
      end
    elsif params[:back]
      logger.debug 'Default, redirecting back to Finish page'
      redirect_to finish_url(:id => @registration.id)
    else
      # Turn off default gov uk template so certificate can be printed exactly as is
      render :layout => "non_govuk_template"
      logger.debug 'Save Print state in the print page (go to Finish)'
      flash[:alert] = 'Finish'
    end
  end

  # GET /your-registration/confirmed
  def confirmed
    @user = session[:user]
    if !@user
      logger.warn "Could not retrieve the activated user. Showing 404."
      #flash[:notice] = 'Error: Could not find user ' + @user.to_s
      renderNotFound and  return
    end

    # If we come this way as part of the upper tier registration then we should have the ID for the
    # registration we are dealing with else we came via a account confirmation link and can only go
    # on the email address of the user.
    reg_uuid = params[:id] || session[:registration_uuid]
    if reg_uuid
      @registration = Registration.find_by_id( reg_uuid )
    else
      @registrations = Registration.find_by_email(@user.email)
      unless @registrations.empty?
        @sorted = @registrations.sort_by { |r| r.date_registered}.reverse!
        @registration = @sorted.first
        session[:registration_uuid] = @registration.uuid
      else
        flash[:notice] = 'Registration list is empty, Found no registrations for user: ' + @user.email.to_s
        renderNotFound and return
      end
    end

    if !@registration
      renderNotFound and return
    end

    @confirmationType = getConfirmationType
    unless @confirmationType
      flash[:notice] = 'Invalid confirmation type. Check routing to this page'
      renderNotFound and return
    end
  end

  def completeConfirmed
    logger.info "Redirect to GDS site"
    #
    # Finished here, ok to clear session variables
    #
    clear_registration_session
    reset_session
    redirect_to Rails.configuration.waste_exemplar_end_url
  end

  def version
    @railsVersion = Rails.configuration.application_version

    # Request version from REST api
    @apiVersionObj = Version.find(:one, :from => "/version.json" )
    if !@apiVersionObj.nil?
      logger.debug 'Version info, version number:' + @apiVersionObj.versionDetails + ' lastBuilt: ' + @apiVersionObj.lastBuilt
      @apiVersion = @apiVersionObj.versionDetails
    end

    render :layout => false
  end

  # Renders static data proctection page
  def dataProtection
  end

  # GET /registrations/new
  # GET /registrations/new.json
  def new
    renderNotFound
  end


  # GET /registrations/1/edit
  def edit
    Rails.logger.debug "registration edit for: #{params[:id]}"
    @registration = Registration.find_by_id(params[:id])
    if !@registration
      renderNotFound and return
    end
    # let's keep track of the original registration before any edits have been done
    # the we can use it to compare it with the edited one.
    session[:original_registration_id] = Registration.find_by_id(params[:id]).id
    authorize! :update, @registration


    session[:registration_id] = @registration.id
    session[:registration_uuid] = @registration.uuid
    session[:edit_mode] =  params[:edit_process] #view param knows if the user clicked edit, renew or recreate
    session[:edit_result] = EditResult::START #initial state
    session[:editing] = true

    redirect_to :newConfirmation
  end

  def paymentstatus
    @registration = Registration.find_by_id(params[:id])
    if @registration.nil?
      renderNotFound
      return
    end
    authorize! :read, @registration
    authorize! :read, Payment
  end

  def check_steps_are_valid_up_until_current current_step
    if !@registration.steps_valid?(current_step)
      redirect_to_failed_page(@registration.current_step)
    else
      logger.debug 'Previous pages are valid'
    end
  end

  def copyAddressToSession
    logger.info 'Copying address details into the registration...'
    logger.info 'The @selected_address is: ' + @selected_address.inspect.to_s

    @registration = Registration[ session[:registration_id]]

    @registration.houseNumber = @selected_address.lines[0] if @selected_address.lines[0]
    @registration.streetLine1 = @selected_address.lines[1] if @selected_address.lines[1]
    @registration.streetLine2 = @selected_address.lines[2] if @selected_address.lines[2]
    @registration.streetLine3 = @selected_address.lines[3] if @selected_address.lines[3]
    @registration.townCity = @selected_address.town  if @selected_address.town
    @registration.postcode = @selected_address.postcode  if @selected_address.postcode
    @registration.uprn = @selected_address.uprn if @selected_address.uprn
    @registration.easting = @selected_address.easting if @selected_address.easting
    @registration.northing = @selected_address.northing if @selected_address.northing
    @registration.dependentLocality = @selected_address.dependentLocality if @selected_address.dependentLocality
    @registration.dependentThroughfare = @selected_address.dependentThroughfare if @selected_address.dependentThroughfare
    @registration.administrativeArea = @selected_address.administrativeArea if @selected_address.administrativeArea
    @registration.localAuthorityUpdateDate = @selected_address.localAuthorityUpdateDate if @selected_address.localAuthorityUpdateDate
    @registration.royalMailUpdateDate = @selected_address.royalMailUpdateDate if @selected_address.royalMailUpdateDate
    @registration.save
  end

  def pending
    @registration = Registration.find_by_id(session[:registration_uuid])

    # May not be necessary but seeing as we get a fuller object from services
    # at this point thought as a 'just in case' we should update the one in redis
    @registration.save

    # user = @registration.user
    # user.current_registration = @registration
    # user.send_confirmation_instructions unless user.confirmed?
  end

  def redirect_to_failed_page(failedStep)
    logger.debug 'redirect_to_failed_page(failedStep) failedStep: ' +  failedStep
    if failedStep == "business"
      redirect_to :newBusinessDetails
    elsif failedStep == "contact"
      redirect_to :newContact
    elsif failedStep == "confirmation"
      redirect_to :newConfirmation
    elsif failedStep == "signup"
      redirect_to :newSignup
    end
  end


  def updatedParameters(databaseMetaData, submittedParams)
    # Save DB MetaData
    dbMetaData = databaseMetaData
    # Create a new Registration from submitted params
    regFromParams = Registration.ctor(submittedParams)
    begin
      metaDataFromParams = regFromParams.metaData
      # Update Saved MD with revoked reason from Param
      dbMetaData.revokedReason = metaDataFromParams.revokedReason
    rescue
      logger.info 'Warning: Cannot find meta data, this could be valid if being edited by an external user, Ignoring for now and continuing'
    end
    regFromParams.metaData = dbMetaData
    regFromParams.attributes
  end



  # DELETE /registrations/1
  # DELETE /registrations/1.json
  def destroy
    #TODO re-introduce when needed
    #renderAccessDenied
    @registration = Registration.find_by_id(params[:id])
    deletedCompany = @registration.companyName
    authorize! :update, @registration
    @registration.metaData.first.update(:status => 'INACTIVE')
    @registration.save!

    if current_user
      respond_to do |format|
        format.html { redirect_to userRegistrations_path(current_user.id, :note => 'Deleted ' + deletedCompany) }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to registrations_path(:note => 'Deleted ' + deletedCompany) }
        format.json { head :no_content }
      end
    end
  end

  def confirmDelete
    @registration = Registration.find_by_id(params[:id])
    authorize! :update, @registration
  end
  #####################################################################################
  # Revoke / Unvoke
  #####################################################################################

  def revoke
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration
    @isRevoke = true
  end

  def unRevoke
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration
    @isRevoke = false
    # Reuses revoke view for un-revoke functionality
    render :revoke
  end

  def updateRevoke
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration

    # Validate if is in a correct state to revoke/unrevoke?
    if params[:revoke]                      # Checks the type of request, ie which button was clicked
      if @registration.is_revocable?        # Checks if revocable, i.e. is registration in a state that can be made revoked
        if !params[:registration][:metaData][:revokedReason].empty?     # Checks the reason was provided
          if agency_user_signed_in?                                     # Checks only agency users can revoke
            # Get reason from params
            revokedReason = params[:registration][:metaData][:revokedReason]
            logger.info 'Revoked Reason: ' + revokedReason.to_s

            # Update registration with revoked comment and status
            @registration.metaData.first.update(revokedReason: revokedReason)
            @registration.metaData.first.update(status: 'REVOKED')

            # Save changes to registration
            @registration.save
            @registration.save!
            logger.debug "uuid: #{@registration.uuid}"

            # We don't send a revoke email, because NCCC handle this process manually.

            # Redirect to registrations page
            redirect_to registrations_path(:note => I18n.t('registrations.form.reg_revoked') ) and return
          else
            renderAccessDenied and return
          end
        else
          # Reason not provided
          @registration.errors.add(:revokedReason, I18n.t('errors.messages.blank'))
        end
      else
        # Error: Not ready for revoke  TODO: Replace this with better message
        @registration.errors.add(:revokedReason, I18n.t('errors.messages.blank'))
      end
    else
      # check if unrevocable
      if @registration.is_unrevocable?
        if !params[:registration][:metaData][:unrevokedReason].empty?
          if agency_user_signed_in?
            # Get reason from params
            unrevokedReason = params[:registration][:metaData][:unrevokedReason]
            logger.info 'Unrevoked Reason: ' + unrevokedReason.to_s

            # Mark registration as unrevoked, i.e. reactivated
            @registration.metaData.first.update(revokedReason: unrevokedReason)
            @registration.metaData.first.update(status: 'ACTIVE')

            # Save changes to registration
            @registration.save
            @registration.save!
            logger.debug "uuid: #{@registration.uuid}"

            # QUESTION: Do we Send email to say reactivated? Resend registration perhaps?

            # Redirect to registrations page
            redirect_to registrations_path(:note => 'Registration reactivated' ) and return
          end
        else
          # Reason not provided
          @registration.errors.add(:unrevokedReason, I18n.t('errors.messages.blank'))
        end
      else
        # Error: Not ready for unrevoke  TODO: Replace this with better message
        @registration.errors.add(:unrevokedReason, I18n.t('errors.messages.blank'))
      end
    end

    # Error must have occured return to original view with errors
    if params[:revoke]
      # from revoke
      @isRevoke = true
      render :revoke, :status => '400'
    else
      # from unrevoke
      @isRevoke = false
      render :revoke, :status => '400'
    end
  end
  #####################################################################################
  # Approve / Refuse
  #####################################################################################

  def approve
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration
    @isApprove = true
  end

  def refuse
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration
    @isApprove = false
    # Reuses approve view for refuse functionality
    render :approve
  end

  def updateApprove
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration

    # Validate if is in a correct state to approve/refuse?
    if params[:approve]
      # Approve
      logger.info '>>>>>> Approve Request Found'
      if !params[:registration][:metaData][:approveReason].empty?     # Checks the reason was provided
        if agency_user_signed_in?                                     # Checks only agency users can approve
          # Get reason from params
          approveReasonParam = params[:registration][:metaData][:approveReason]

          # Update registration with revoked comment and status
          @registration.metaData.first.update(revokedReason: approveReasonParam)
          #@registration.metaData.first.update(status: 'ACTIVE')                    # Should not need to do this directly if conviction check has been cleared

          # Perform action needed to clear conviction check
          if @registration.conviction_sign_offs
            @registration.conviction_sign_offs.each do |sign_off|
              # Update conviction sign off data
              sign_off.update(confirmed: 'yes')
              sign_off.update(confirmedAt: Time.now.utc.xmlschema)
              sign_off.update(confirmedBy: current_agency_user.email)
            end
          end

          # Save changes to registration
          if @registration.save!
            @registration.save
            logger.debug "uuid: #{@registration.uuid}"

            @user = User.find_by_email(@registration.accountEmail)
            RegistrationMailer.welcome_email(@user, @registration).deliver

            # Redirect to registrations page
            redirect_to registrations_path(:note => I18n.t('registrations.form.reg_approved') ) and return
          else
            # Failed to save registration in database
            @registration.errors.add(:exception, 'Failed to save approve in DB')
          end
        else
          renderAccessDenied and return
        end
      else
        @registration.errors.add(:approveReason, I18n.t('errors.messages.blank'))
      end
    else
      # Refuse
      if @registration.is_awaiting_conviction_confirmation?(current_agency_user)        # Checks if refusable, i.e. is registration in a state that can be made refused
        if !params[:registration][:metaData][:refusedReason].empty?                     # Checks the reason was provided
          # Get reason from params
          refusedReasonParam = params[:registration][:metaData][:refusedReason]

          # Update registration with refused comment and status
          @registration.metaData.first.update(revokedReason: refusedReasonParam)
          @registration.metaData.first.update(status: 'REFUSED')

          # Save changes to registration
          if @registration.save!
            @registration.save
            logger.debug "uuid: #{@registration.uuid}"

            # Redirect to registrations page
            redirect_to registrations_path(:note => I18n.t('registrations.form.reg_refused') ) and return
          else
            # Failed to save registration in database
            @registration.errors.add(:exception, @registration.exception.to_s)
          end
        else
          @registration.errors.add(:refusedReason, I18n.t('errors.messages.blank'))
        end
      else
        renderAccessDenied and return
      end
    end

    # Error must have occured return to original view with errors
    if params[:approve]
      # from approve
      @isApprove = true
      render :approve, :status => '400'
    else
      # from refuse
      @isApprove = false
      render :approve, :status => '400'
    end
  end

  #####################################################################################

  def publicSearch
    distance = params[:distance]
    searchString = params[:q]
    postcode = params[:postcode]
    if validate_public_search_parameters?(searchString,"any",distance, postcode)
      if searchString && !searchString.empty?


        param_args = {
          q: searchString,
          searchWithin: 'companyName',
          distance: distance,
          activeOnly: 'true',
          postcode: postcode,
        excludeRegId: 'true' }


        @registrations = Registration.find_by_params(param_args)
      else
        @registrations = []
      end
    else
      @registrations = []
      flash.now[:notice] = I18n.t('registrations.form.invalid_public_params')
    end
  end

  def notfound
    redirect_to registrations_path(:error => params[:message] )
  end

  def logger
    Rails.logger
  end

  def authenticate_admin_request!
    if is_admin_request?
      authenticate_agency_user!
    end
  end

  def authenticate_external_user!
    if !is_admin_request? && !agency_user_signed_in?
      authenticate_user!
    end
  end


  # Function to redirect newOrders to the order controller
  def newOrder registration_uuid
    #
    # Important!
    # Now storing an additional variable in the session for the type of order
    # you are about to make.
    # This session variable needs to be set every time the order/new action
    # is requested.
    #
    session[:renderType] = Order.new_registration_identifier
    session[:orderCode] = generateOrderCode
    redirect_to upper_payment_path(:id => registration_uuid)
  end

  # Function to redirect registration edit orders to the order controller
  def newOrderEdit registration_uuid
    session[:renderType] = Order.edit_registration_identifier
    session[:orderCode] = generateOrderCode
    redirect_to upper_payment_path(:id => registration_uuid)
  end

  # Function to redirect registration renew orders to the order controller
  def newOrderRenew registration_uuid
    session[:renderType] = Order.renew_registration_identifier
    session[:orderCode] = generateOrderCode
    redirect_to upper_payment_path(:id => registration_uuid)
  end

  # Function to redirect additional copy card orders to the order controller
  def newOrderCopyCards
    clear_registration_session
    session[:renderType] = Order.extra_copycards_identifier
    session[:orderCode] = generateOrderCode
    redirect_to upper_payment_path
  end

  # Function to redirect renewal which caused new registration to the order controller
  def newOrderCausedNew registration_uuid
    session[:renderType] = Order.editrenew_caused_new_identifier
    session[:orderCode] = generateOrderCode
    redirect_to upper_payment_path(:id => registration_uuid)
  end

  # Renders the additional copy card order complete view
  def copyCardComplete
    @registration = Registration.find_by_id(params[:id])
    @confirmationType = getConfirmationType
    authorize! :read, @registration
  end

  # Renders the edit renew order complete view
  def editRenewComplete

    logger.debug "original id" + session[:original_registration_id].to_s
    logger.debug "new id" + session[:registration_uuid].to_s
    logger.debug "params id" + params[:id].to_s
    @registration = Registration.find_by_id(params[:id])
    #need to store session variables as instance variable, so that editRenewComplete.html can
    #use them, as session will be cleared shortly
    @edit_mode = session[:edit_mode]
    @edit_result = session[:edit_result]
    logger.debug '@edit_mode: ' + @edit_mode.to_s
    logger.debug '@edit_result: ' + @edit_result.to_s

    @confirmationType = getConfirmationType


    # Determine routing for Finish button
    if @registration.originalRegistrationNumber and isIRRegistrationType(@registration.originalRegistrationNumber) and @registration.newOrRenew
      @exitRoute = confirmed_path
    else
      if current_agency_user
        @exitRoute = finishAssisted_path
      else
        @exitRoute = registrations_finish_path
      end
    end

  end

  def newOfflinePayment
    # Check is registration still in session, if not render denied page
    regUuid = session[:registration_uuid]
    if regUuid
      @registration = Registration.find_by_id(regUuid)
      # Get the order just made from the order code param
      if @registration
        @order = @registration.getOrder(params[:orderCode])
      else
        renderNotFound
      end
    else
      logger.warn 'Attempting to access registration from uuid in session, but no uuid is in the session. Showing Not Found'
      renderNotFound
    end
  end

  def updateNewOfflinePayment
    @registration = Registration.find_by_id(session[:registration_uuid])

    # Get renderType from recent order
    renderType = session[:renderType]

    # Validate that actions only occur here if a render type is
    if !renderType
      # If the renderType has been cleared you have already gone through this controller
      # thus any subsequent action renders the access denied page
      renderAccessDenied and return
    end

    # Removed as craete_new_reg not required here as already saved prior to order page
    #    # Check if a new registration is required, and create prior to deleting session variables
    #    if EditResult::CREATE_NEW_REGISTRATION.eql? session[:edit_result].to_i and !create_new_reg
    #      # redirect to previous page due to error
    #      redirect_to newOfflinePayment_path and return
    #    end

    #
    # This should be an acceptable time to delete the render type and
    # the order code from the session, as these are used for payment
    # and if reached here payment request succeeded
    #
    session.delete(:renderType)
    session.delete(:orderCode)

    # Should also Clear other registration variables for other routes...
    if renderType.eql?(Order.extra_copycards_identifier)
      clear_registration_session
    end

    if @registration.digital_route? and !renderType.eql?(Order.extra_copycards_identifier)
      logger.info 'Send registered email (if not agency user)'
      @user = User.find_by_email(@registration.accountEmail)
      Registration.send_registered_email(@user, @registration)
    end

    next_step = if renderType.eql?(Order.extra_copycards_identifier)
      # redirect to copy card complete page
      complete_copy_cards_path(@registration.uuid)
    elsif renderType.eql?(Order.edit_registration_identifier)
      # redirect to edit complete
      complete_edit_renew_path(@registration.uuid)
    elsif renderType.eql?(Order.renew_registration_identifier)
      # redirect to renew complete
      complete_edit_renew_path(@registration.uuid)
    elsif user_signed_in?
      finish_path
    elsif agency_user_signed_in?
      finishAssisted_path
    else
      confirmed_path
    end

    redirect_to next_step

  end

  def compare_registrations(edited_registration, original_registration)
    res =  EditResult::UPDATE_EXISTING_REGISTRATION_NO_CHARGE
    logger.debug "#{original_registration.attributes}"
    logger.debug "#{edited_registration.attributes}"

    #
    # PT 81010558 : Disallow the user to change tier
    #
    if (original_registration.tier != edited_registration.tier)
      logger.debug 'Registration has changed Tier, Not Allowed'
      res = EditResult::CHANGE_NOT_ALLOWED
    else
      #
      # BUSINESS RULES for Determining NEW REGISTRATION:
      # A new registration is created if the following changes are made:
      #   1. Change of legal entity
      #   2. Change of companies house number
      #   3. A partner is added to a Partnership (Partnership legal entity only
      #

      if (original_registration.originalRegistrationNumber) and \
          (isIRRegistrationType(original_registration.originalRegistrationNumber)) and \
          (original_registration.key_people.size.to_i == 0)
        # Assumed, 0 Key people is from an IR data import
        if (original_registration.businessType != edited_registration.businessType) ||
            (edited_registration.company_no != original_registration.company_no)
          # NEW REGISTRATION Rule: 1 and 2
          logger.debug 'NEW REG because Rule 1 or 2 (test 1)'
          res = EditResult::CREATE_NEW_REGISTRATION
        elsif (original_registration.registrationType != edited_registration.registrationType)
          logger.debug 'Update REG WITH CHARGE (test 4)'
          res = EditResult::UPDATE_EXISTING_REGISTRATION_WITH_CHARGE
        else
          logger.debug "Standard IR Renewal Charge"
          logger.debug 'Update REG NO CHARGE (test 5)'
          res = EditResult::UPDATE_EXISTING_REGISTRATION_NO_CHARGE
        end
      else
        if (original_registration.businessType != edited_registration.businessType) ||
            (edited_registration.company_no != original_registration.company_no)
          # NEW REGISTRATION Rule: 1 and 2
          logger.debug 'NEW REG because Rule 1 or 2 (test 2)'
          res = EditResult::CREATE_NEW_REGISTRATION
        elsif (edited_registration.businessType == Registration::BUSINESS_TYPES[1]) &&
            (original_registration.key_people.size < edited_registration.key_people.size )
          # NEW REGISTRATION Rule: 3
          logger.debug 'NEW REG because Rule 3 (test 3)'
          logger.debug 'size before: ' + original_registration.key_people.size.to_s
          logger.debug 'size after : ' + edited_registration.key_people.size.to_s
          res = EditResult::CREATE_NEW_REGISTRATION
        elsif (original_registration.registrationType != edited_registration.registrationType)
          logger.debug 'Update REG WITH CHARGE (test 6)'
          res = EditResult::UPDATE_EXISTING_REGISTRATION_WITH_CHARGE
        end
      end
    end

    res

  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def registration_params
    params.require(:registration).permit(
      :businessType,
      :registrationType,
      :otherBusinesses,
      :isMainService,
      :constructionWaste,
      :onlyAMF,
      :companyName,
      :addressMode,
      :houseNumber,
      :streetLine1,
      :streetLine2,
      :streetLine3,
      :streetLine4,
      :country,
      :townCity,
      :postcode,
      :postcodeSearch,
      :firstName,
      :lastName,
      :position,
      :phoneNumber,
      :contactEmail,
      :accountEmail,
      :declaration,
      :password,
      :password_confirmation,
      :accountEmail_confirmation,
      :tier,
      :company_no,
      :registration_fee,
      :copy_card_fee,
      :copy_cards,
      :total_fee,
      :address_match_list,
    :sign_up_mode)
  end

end
