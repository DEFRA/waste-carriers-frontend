class RegistrationsController < ApplicationController

  #We require authentication (and authorisation) largely only for editing registrations,
  #and for viewing the finished/completed registration.

  before_filter :authenticate_admin_request!

  before_filter :authenticate_external_user!, :only => [:update, :ncccedit, :ncccupdate, :destroy, :finish, :print]

  # GET /registrations
  # GET /registrations.json
  def index
    authenticate_agency_user!
    searchWithin = params[:searchWithin]
    searchString = params[:q]
    if valid_search_parameters?(searchString,searchWithin)
      @registrations = if searchString.present?
        Registration.find(:all, :params => {:q => searchString, :searchWithin => searchWithin})
      else
        []
      end
    else
      @registrations = []
      flash.now[:notice] = 'You must provide valid search parameters. Please only use letters, numbers,or any of \' . & ! %.'
    end
    session[:registration_step] = session[:registration_params] = nil

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrations }
    end
end

  # GET /your-registration/business-type
  def newBusinessType
    new_step_action 'businesstype'

    @registration.routeName = params[:agency].present? ? 'ASSISTED_DIGITAL' : 'DIGITAL'
  end

  # POST /your-registration/business-type
  def updateNewBusinessType
    setup_registration 'businesstype'

    if @registration.valid?
      logger.info 'Registration is valid so far, go to next page'
      # TODO set steps

      case @registration.businessType
        when 'soleTrader', 'partnership', 'limitedCompany', 'publicBody'
          @registration.steps = %w[businesstype otherbusinesses]
          redirect_to :newOtherBusinesses
        when 'charity', 'authority'
          @registration.steps = %w[businesstype business]
          redirect_to :newBusinessDetails
        when 'other'
          @registration.steps = %w[businesstype noregistration]
          redirect_to :newNoRegistration
      end
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newBusinessType", :status => '400'
      #redirect_to newBusinessDetails_path
    end
  end

  # GET /your-registration/no-registration
  def newNoRegistration
    new_step_action 'noregistration'
  end

  # POST /your-registration/no-registration
  def updateNewNoRegistration
    setup_registration 'noregistration'

    # TODO set steps

    if @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newNoRegistration", :status => '400'
    end
  end

  # GET /your-registration/other-businesses
  def newOtherBusinesses
    new_step_action 'otherbusinesses'
  end

  # POST /your-registration/other-businesses
  def updateNewOtherBusinesses
    setup_registration 'otherbusinesses'

    if @registration.valid?
      # TODO this is where you need to make the choice and update the steps
      case @registration.otherBusinesses
        when 'yes'
          redirect_to :newServiceProvided
        when 'no'
          redirect_to :newConstructionDemolition
      end
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newOtherBusinesses", :status => '400'
    end
  end

  # GET /your-registration/service-provided
  def newServiceProvided
    new_step_action 'serviceprovided'
  end

  # POST /your-registration/service-provided
  def updateNewServiceProvided
    setup_registration 'serviceprovided'

    if @registration.valid?
      # TODO this is where you need to make the choice and update the steps
      case @registration.isMainService
        when 'yes'
          redirect_to :newOnlyDealWith
        when 'no'
          redirect_to :newConstructionDemolition
      end
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newServiceProvided", :status => '400'
    end
  end

  # GET /your-registration/construction-demolition
  def newConstructionDemolition
    new_step_action 'constructiondemolition'
    session[:registration_phase] = 'smart'
  end

  # POST /your-registration/construction-demolition
  def updateNewConstructionDemolition
    setup_registration 'constructiondemolition'

    if @registration.valid?
      # TODO this is where you need to make the choice and update the steps
      case @registration.constructionWaste
        when 'yes'
        session[:registration_phase] = 'upper'
          redirect_to :newRegistrationType
        when 'no'
        session[:registration_phase] = 'lower'
          redirect_to :newBusinessDetails
      end
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newConstructionDemolition", :status => '400'
    end
  end

  # GET /your-registration/only-deal-with
  def newOnlyDealWith
    new_step_action 'onlydealwith'
  end

  # POST /your-registration/only-deal-with
  def updateNewOnlyDealWith
    setup_registration 'onlydealwith'

    if @registration.valid?
      # TODO this is where you need to make the choice and update the steps
      case @registration.onlyAMF
        when 'yes'
          redirect_to :newBusinessDetails
        when 'no'
          redirect_to :newRegistrationType
      end
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newOnlyDealWith", :status => '400'
    end
  end

  # GET /your-registration/business-details
  def newBusinessDetails
    new_step_action 'businessdetails'
    addressSearchLogic @registration
  end

  # POST /your-registration/business-details
  def updateNewBusinessDetails
    setup_registration 'businessdetails'
    addressSearchLogic @registration

    if params[:findAddress]
      render "newBusinessDetails"
    elsif @registration.valid?
      session[:registration_phase] == 'upper' ? (redirect_to :newUpperBusinessDetails) : (redirect_to :newContact)
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newBusinessDetails", :status => '400'
    end
  end

  # GET /your-registration/contact-details
  def newContactDetails
    new_step_action 'contactdetails'
    addressSearchLogic @registration
  end

  # POST /your-registration/contact-details
  def updateNewContactDetails
    setup_registration 'contactdetails'

    if @registration.valid?
      redirect_to :newConfirmation
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newContactDetails", :status => '400'
    end
  end

  # GET /your-registration/registration-type
  def newRegistrationType
    new_step_action 'registrationtype'
    session[:registration_phase] = 'upper'
  end

  # POST /your-registration/registration-type
  def updateNewRegistrationType
    setup_registration 'registrationtype'
    @registration.registration_phase = 'upper'
    if @registration.valid?
      redirect_to :newUpperBusinessDetails

    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newRegistrationType", :status => '400'
    end
  end

  # GET /your-registration/confirmation
  def newConfirmation
    new_step_action 'confirmation'
  end

  # POST /your-registration/confirmation
  def updateNewConfirmation
    setup_registration 'confirmation'

    if @registration.valid?
      redirect_to :newSignup
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newConfirmation", :status => '400'
    end
  end

  # GET /registrations/data-protection
  def dataProtection
    # Renders static data proctection page
  end

  def new_step_action current_step
    session[:registration_params] ||= {}
    session[:registration_params].deep_merge!(registration_params) if params[:registration]
    @registration = Registration.new(session[:registration_params])

    # TODO by setting the step here this should work better with forward and back buttons and urls
    # but this might have changed the behaviour
    @registration.current_step = current_step
    # Pass in current page to check previous page is valid
    # TODO had to comment this out for now because causing problems but will probably need to reinstate
    # check_steps_are_valid_up_until_current current_step
  end

  def setup_registration current_step
    session[:registration_params] ||= {}
    session[:registration_params].deep_merge!(registration_params) if params[:registration]
    @registration= Registration.new(session[:registration_params])
    @registration.current_step = current_step
  end

  def valid_search_parameters?(searchString, searchWithin)
    searchString_valid = searchString.nil? || searchString.match(Registration::VALID_CHARACTERS)
    searchWithin_valid = searchWithin.blank? || (['any','companyName','contactName','postcode'].include? searchWithin)
    searchString_valid && searchWithin_valid
  end

  def valid_public_search_parameters?(searchString, searchWithin, searchDistance, searchPostcode)
    searchString_valid = searchString.nil? || (!searchString.match(Registration::VALID_CHARACTERS).nil?)
    searchWithin_valid = searchWithin.nil? || (['any','companyName','contactName','postcode'].include? searchWithin)
    searchDistance_valid = searchDistance.nil? || (Registration::DISTANCES.include? searchDistance)
    searchPostcode_valid = searchPostcode.blank? || searchPostcode.match(Registration::POSTCODE_CHARACTERS)

    searchCrossField_valid = true
    # Add cross field check, to ensure that correct params supplied if needed
    if searchString.present?
      if searchDistance.nil? || searchPostcode.nil?
        searchCrossField_valid = false
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
      renderAccessDenied
    elsif current_user.email != tmpUser.email
      renderAccessDenied
    else
	  # Search for users registrations
      @registrations = Registration.find(:all, :params => {:ac => tmpUser.email}).sort_by { |r| r.date_registered}
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
  	begin
      @registration = Registration.find(params[:id])
    rescue ActiveResource::ResourceNotFound
      redirect_to registrations_path(:error => 'Could not find registration: ' + params[:id])
      return
    end

    authorize! :read, @registration
    if params[:finish]
      if agency_user_signed_in?
        logger.info 'Keep agency user signed in before redirecting back to search page'
        redirect_to registrations_path
      else
        logger.info 'Sign user out before redirecting back to GDS site'
        sign_out 				# Performs a signout action on the current user
        redirect_to Rails.configuration.waste_exemplar_end_url
      end
    elsif params[:back]
      if params[:from] == "NCCCEdit"
        logger.debug 'From page found, redirecting back to NCCC edit'
        redirect_to ncccedit_path(:id => @registration.id)
      else
        logger.debug 'Default, redirecting back to Finish page'
        redirect_to finish_url(:id => @registration.id)
      end
    else
      if params[:reprint]
        logger.debug 'Save Reprint state in the print page (go to NCCCedit)'
        flash[:alert] = 'NCCCEdit'
      else
        logger.debug 'Save Print state in the print page (go to Finish)'
        flash[:alert] = 'Finish'
      end
	  render :layout => 'printview'
    end
  end


  def confirmed
    @user = session[:confirmed_user]
    if !@user
      logger.warn "Could not retrieve the activated user. Showing 404."
      renderNotFound
      return
    end
    @registrations = Registration.find(:all, :params => {:ac => @user.email})
    if @registrations.size > 0
      @sorted = @registrations.sort_by { |r| r.date_registered}.reverse!
      @registration = @sorted.first
      session[:registration_id] = @registration.id
    else
      renderNotFound
      return
    end
    #render the confirmed page
  end


  def print_confirmed
    begin
      @registration = Registration.find(session[:registration_id])
    rescue ActiveResource::ResourceNotFound
      renderNotFound
      return
    end

    if params[:finish]
      if agency_user_signed_in?
        logger.info 'Keep agency user signed in before redirecting back to search page'
        redirect_to registrations_path
      else
        reset_session
        redirect_to Rails.configuration.waste_exemplar_end_url
      end
    elsif params[:back]
      logger.debug 'Default, redirecting back to Finish page'
      redirect_to confirmed_url
    else
      render :layout => 'printview'
    end
  end


  def finish
    @registration = Registration.find(params[:id])
    authorize! :read, @registration
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
    session[:registration_params] ||= {}
    @registration = Registration.find(params[:id])
    authorize! :update, @registration
    if !@registration.metaData.status.nil? && @registration.metaData.status == "REVOKED"
      logger.info "Edit not allowed, as registration has been revoked"
      redirect_to userRegistrations_path(current_user.id)
    end
    @registration.current_step = session[:registration_step]
  end

  def ncccedit
    @registration = Registration.find(params[:id])
    @registration.routeName = @registration.metaData.route
    addressSearchLogic @registration
    authorize! :update, @registration
  end

  def check_steps_are_valid_up_until_current current_step
    if !@registration.steps_valid?(current_step)
      redirect_to_failed_page(@registration.current_step)
    else
      logger.debug 'Previous pages are valid'
    end
  end

  def clearAddressNonManual(registration)
    registration.uprn = nil
    registration.postcodeSearch = nil
    registration.selectedMoniker = nil
    registration.easting = nil
    registration.northing = nil
    registration.dependentLocality = nil
    registration.dependentThroughfare = nil
    registration.administrativeArea = nil
    registration.localAuthorityUpdateDate = nil
    registration.royalMailUpdateDate = nil
  end

  def clearAddressNonUk(registration)
    clearAddressNonManual registration
    registration.streetLine3 = nil
    registration.streetLine4 = nil
    registration.country = nil
  end

  def clearAddressNonForeign(registration)
    clearAddressNonManual registration
    registration.townCity = nil
    registration.postcode = nil
  end

  def clearAddress(registration)
    clearAddressNonManual registration
    registration.streetLine1 = nil
    registration.streetLine2 = nil
    registration.streetLine3 = nil
    registration.streetLine4 = nil
    registration.country = nil
    registration.townCity = nil
    registration.postcode = nil
  end

  def addressSearchLogic(registration)

    @addresses = []
    if params[:sManual]
      registration.addressMode = "manual-uk"
    elsif params[:sManualForeign]
      registration.addressMode = "manual-foreign"
    elsif params[:sSearch] or params[:sPostcode]
      registration.addressMode = nil
      clearAddress registration
    end

    if registration.addressMode == "manual-foreign"
      clearAddressNonForeign registration
    elsif registration.addressMode == "manual-uk"
      clearAddressNonUk registration
    end

    if params[:sPostcode]
      registration.postcodeSearch = params[:sPostcode]
    end

    postcodeSearch = registration.postcodeSearch
    if postcodeSearch.present?
      postcode = registration.postcodeSearch
      logger.info "getting addresses for: "+postcode
      begin
        @addresses = Address.find(:all, :params => {:postcode => postcode})
      rescue ActiveResource::ServerError
        @addresses = []
      #
      # TMP HACK ---
      #
      rescue Errno::ECONNREFUSED
        # This overrides default behaviour for service not running, by logging and carrying on rather than,
        # redirecting to service unavailable page. This is currently neccesary to navigate using the system
        # if the service is not running.
        logger.error 'ERROR: Address Lookup Not running, or not Found'
        @addresses = []
      #
      # ---
      #
      end
      if @addresses.length == 1
        registration.selectedMoniker =  @addresses[0].moniker
        @address = @addresses[0]
      else
        @address = nil
      end
    end

    if params[:sSelect].present?
      registration.selectedMoniker = params[:sSelect]
    end
    selectedMoniker = registration.selectedMoniker
    if selectedMoniker.present? and !@address
      logger.info "Getting address for: "+selectedMoniker
      @address = Address.find(selectedMoniker)
    end

    if @address and @address.lines!=nil
      registration.streetLine1 = @address.lines[0]
      registration.streetLine2 = @address.lines[1]
      registration.streetLine3 = @address.lines[2]
      registration.streetLine4 = @address.lines[3]
      registration.townCity = @address.town
      registration.postcode = @address.postcode
      registration.uprn = @address.uprn
      registration.easting = @address.easting
      registration.northing = @address.northing
      registration.dependentLocality = @address.dependentLocality
      registration.dependentThroughfare = @address.dependentThroughfare
      registration.administrativeArea = @address.administrativeArea
      registration.localAuthorityUpdateDate = @address.localAuthorityUpdateDate
      registration.royalMailUpdateDate = @address.royalMailUpdateDate
    end
  end

  def copyAddressToSession(registration)
  	  session[:registration_params][:addressMode] = registration.addressMode
  	  session[:registration_params][:streetLine1] = registration.streetLine1
      session[:registration_params][:streetLine2] = registration.streetLine2
      session[:registration_params][:streetLine3] = registration.streetLine3
      session[:registration_params][:streetLine4] = registration.streetLine4
      session[:registration_params][:townCity] = registration.townCity
      session[:registration_params][:postcode] = registration.postcode
      session[:registration_params][:uprn] = registration.uprn
      session[:registration_params][:easting] = registration.easting
      session[:registration_params][:northing] = registration.northing
      session[:registration_params][:dependentLocality] = registration.dependentLocality
      session[:registration_params][:dependentThroughfare] = registration.dependentThroughfare
      session[:registration_params][:administrativeArea] = registration.administrativeArea
      session[:registration_params][:localAuthorityUpdateDate] = registration.localAuthorityUpdateDate
      session[:registration_params][:royalMailUpdateDate] = registration.royalMailUpdateDate
  end

  def newSignup
    session[:registration_params] ||= {}
    session[:registration_params].deep_merge!(registration_params) if params[:registration]
    @registration = Registration.new(session[:registration_params])

    # Pass in current page to check previous page is valid
    if !@registration.steps_valid?("signup")
      redirect_to_failed_page(@registration.current_step)
    else
      logger.debug 'Previous pages are valid'

	  # Prepopulate Email field/Set registration account
	  if user_signed_in?
	    logger.debug 'User already signed in using current email: ' + current_user.email
	    @registration.accountEmail = current_user.email
	  elsif agency_user_signed_in?
	    logger.debug 'Agency User already signed in using current email: ' + current_agency_user.email
	    @registration.accountEmail = current_agency_user.email
	  else
	    logger.debug 'User NOT signed in using contact email: ' + @registration.contactEmail
	    @registration.accountEmail = @registration.contactEmail
	  end
	  # Get signup mode
	  @registration.sign_up_mode = @registration.initialize_sign_up_mode(@registration.accountEmail, (user_signed_in? || agency_user_signed_in?))
	  logger.debug 'registration mode: ' + @registration.sign_up_mode
    end
  end

  def updateNewSignup
    logger.info 'updateNewSignup()'
    session[:registration_params] ||= {}
    session[:registration_params].deep_merge!(registration_params) if params[:registration]
    @registration = Registration.new(session[:registration_params])
    @registration.current_step = "signup"

    # Prepopulate Email field/Set registration account
    if user_signed_in?
      logger.debug 'User already signed in using current email: ' + current_user.email
      @registration.accountEmail = current_user.email
    elsif agency_user_signed_in?
      logger.debug 'Agency User already signed in using current email: ' + current_agency_user.email
      @registration.accountEmail = current_agency_user.email
    end
    @registration.sign_up_mode = @registration.initialize_sign_up_mode(@registration.accountEmail, (user_signed_in? || agency_user_signed_in?))
    if @registration.valid?
      logger.info 'Registration is valid so far, go to next page'
      if @registration.sign_up_mode == 'sign_up'
        logger.debug "The registration's sign_up_mode is sign_up: Creating, saving and signing in user " + @registration.accountEmail
        @user = User.new
        @user.email = @registration.accountEmail
        @user.password = @registration.password
        logger.debug "About to save the new user."
        @user.save!
        logger.debug "User has been saved."
        ## the newly created user has to active his account before being able to sign in

        # Reset Signed up user to signed in status
        @registration.sign_up_mode = 'sign_in'
	    else
        logger.debug "Registration sign_up_mode is NOT sign_up. sign_up_mode = " + @registration.sign_up_mode.to_s
        if @registration.sign_up_mode == 'sign_in'
          @user = User.find_by_email(@registration.accountEmail)
          if @user.valid_password?(@registration.password)
            if @user.confirmed?
              logger.info "The user's password is valid and the account is confirmed. Signing in user " + @user.email
              sign_in @user
            else
              logger.warn "User account not yet confirmed for " + @user.email
            end
          else
            logger.error "GGG ERROR - password not valid for user with e-mail = " + @registration.accountEmail
            #TODO error - should have caught the error in validation
            raise "error - invalid password - should have been caught before in validation"
          end
        else
          logger.debug "User signed in, set account email to user email and get user"
          if user_signed_in?
            @registration.accountEmail = current_user.email
          elsif agency_user_signed_in?
            @registration.accountEmail = current_agency_user.email
          end
          @user = User.find_by_email(@registration.accountEmail)
        end
      end

	    logger.debug "Now asking whether registration is all valid"
      if @registration.all_valid?
        logger.debug "The registration is all valid. About to save the registration..."
        @registration.save!
        logger.info 'Perform an additional save, to set the Route Name in metadata'
        logger.info 'routeName = ' + @registration.routeName
        @registration.metaData.route = @registration.routeName
        if agency_user_signed_in?
          @registration.accessCode = @registration.generate_random_access_code
        end
        # The user is signed in at this stage if he activated his e-mail/account (for a previous registration)
        # Assisted Digital registrations (made by the signed in agency user) do not need verification either.
        if agency_user_signed_in? || user_signed_in?
          @registration.activate!
        end
        @registration.save!
        session[:registration_id] = @registration.id
        logger.debug "The registration has been saved. About to send e-mail..."
        if user_signed_in?
          RegistrationMailer.welcome_email(@user, @registration).deliver
        end
        logger.debug "registration e-mail has been sent."
      else
        logger.error "GGG - The registration is NOT valid!"
      end

      # Clear session and redirect to Finish
      session[:registration_step] = session[:registration_params] = nil
      if !@registration.id.nil?
        ## Account not yet activated for new user. Cannot redirect to the finish URL
        if agency_user_signed_in? || user_signed_in?
          redirect_to finish_url(:id => @registration.id)
        else
          redirect_to pending_url
        end
      else
        # Registration Id not found, must have done something wrong
        logger.info 'Registration Id not found, must have done something wrong'
        render :file => "/public/session_expired.html", :status => 400
      end
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newSignup", :status => '400'
    end
  end

  def pending
    @registration = Registration.find(session[:registration_id])
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




  #PUT...
  def ncccupdate
    @registration = Registration.find(params[:id])
    addressSearchLogic @registration
    authorize! :update, @registration


    if params[:findAddress]
      render "ncccedit"
    elsif params[:reprint]
      logger.debug 'Redirect to Print page'
      redirect_to print_url(:id => params[:id], :reprint => params[:reprint])
    elsif params[:revoke]
      if agency_user_signed_in?
        logger.info 'Revoke action detected'

        # Merge param information with registration from DB
        @registration.update_attributes(updatedParameters(@registration.metaData, params[:registration]))

        # Forceably set the revoked value in the registration to now check for a revoke reason
        if params[:revoke_question] == 'yes'
          logger.info 'Revoke set, so should now run additional rule'
          @registration.revoked = 'true'
        end

        if @registration.all_valid?
          @registration.metaData.status = "REVOKED"
          @registration.revoked = ''
          @registration.save

          logger.info 'About to send revoke email'
          @user = User.find_by_email(@registration.accountEmail)
          RegistrationMailer.revoke_email(@user, @registration).deliver

          redirect_to ncccedit_path(:note => I18n.t('registrations.form.reg_revoked') )
        else
          render "ncccedit"
        end
      else
        renderAccessDenied
      end
    elsif params[:unrevoke] && agency_user_signed_in?
      if agency_user_signed_in?
        logger.info 'Revoke action detected'
        @registration.metaData.status = "ACTIVE"
        @registration.save
        redirect_to ncccedit_path(:note => I18n.t('registrations.form.reg_unrevoked'))
      else
        renderAccessDenied
      end
    else
      logger.info 'About to Update Registration'
      if agency_user_signed_in?
        # Merge param information with registration from DB
        @registration.update_attributes(updatedParameters(@registration.metaData, params[:registration]))
      else
        @registration.update_attributes(params[:registration])
      end
      # Set routeName from DB before validation to ensure correct validation for registration type, e.g. ASSITED_DIGITAL or DIGITAL
      @registration.routeName = @registration.metaData.route
      if @registration.all_valid?
        @registration.save
        if agency_user_signed_in?
          redirect_to registrations_path(:note => I18n.t('registrations.form.reg_updated') )
        else
          redirect_to userRegistrations_path(:id => current_user.id, :note => I18n.t('registrations.form.reg_updated') )
        end
      else
        render "ncccedit"
      end
    end
  end

  def updatedParameters(databaseMetaData, submittedParams)
    # Save DB MetaData
    dbMetaData = databaseMetaData
    # Create a new Registration from submitted params
    regFromParams = Registration.new(submittedParams)
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
    @registration = Registration.find(params[:id])
    deletedCompany = @registration.companyName
    authorize! :update, @registration
    @registration.destroy

    respond_to do |format|
      format.html { redirect_to userRegistrations_path(current_user.id, :note => 'Deleted ' + deletedCompany) }
      format.json { head :no_content }
    end
  end

  def confirmDelete
    @registration = Registration.find(params[:id])
    authorize! :update, @registration
  end

  def publicSearch
    distance = params[:distance]
    searchString = params[:q]
    postcode = params[:postcode]
    if valid_public_search_parameters?(searchString,"any",distance, postcode)
      @registrations = if searchString.present?
        Registration.find(:all, :params => {:q => searchString, :searchWithin => 'companyName', :distance => distance, :activeOnly => 'true', :postcode => postcode, :excludeRegId => 'true' })
      else
        []
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
########## Upper Tier Regisration #####################

  def update_model(current_step)

    # @registration = Registration.new
    session[:registration_params] ||= {}
    # session[:registration_params].deep_merge!(upper_reg_params) if params[:upper_registration]

    @registration = Registration.new(session[:registration_params])
    @registration.current_step = current_step
  end

 # GET your-registration/upper-tier-contact-details
  def newUpperBusinessDetails
    new_step_action 'upper_business_details'
        addressSearchLogic @registration
  end

  # POST your-registration/upper-tier-contact-details
  def updateNewUpperBusinessDetails

    setup_registration 'upper_business_details'


    if @registration.valid?
      redirect_to :newUpperContactDetails
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newUpperBusinessDetails", :status => '400'
    end

  end



# GET your-registration/upper-tier-contact-details
  def newUpperContactDetails
    new_step_action 'upper_contact_details'
    addressSearchLogic @registration
  end

  # POST your-registration/upper-tier-contact-details
  def updateNewUpperContactDetails

    setup_registration 'upper_contact_details'
       addressSearchLogic @registration

    if params[:findAddress]
      render "newBusinessDetails"
    elsif @registration.valid?
      redirect_to :upper_payment
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "updateNewUpperContactDetails", :status => '400'
    end
  end

   # GET upper-registrations/payment
  def newPayment
    new_step_action 'payment'
   @registration.registration_fee = 154
   @registration.copy_cards = 2
    @registration.copy_card_fee = @registration.copy_cards * 5
     @registration.total_fee =  @registration.registration_fee + @registration.copy_card_fee
    # update_model("payment")
  end

  # POST upper-registrations/payment
  def updateNewPayment
    setup_registration 'payment'
    # update_model("payment")

    if @registration.valid?
      redirect_to :upper_summary
    else render 'newPayment', :status => '400'

    end
  end

  # GET upper-registrations/summary
  def newUpperSummary
       new_step_action 'upper_summary'
  end

  # POST upper-registrations/summary
  def updateNewUpperSummary

    setup_registration 'upper_summary'

    if @registration.valid?
      redirect_to :newSignup
    else render 'newUpperSummary', :status => '400'
    end
  end
######################################

private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def registration_params
    params.require(:registration).permit(
      :company_house_number,
      :alt_first_name,
      :alt_last_name,
      :alt_job_title,
      :alt_telephone_number,
      :alt_email_address,
      :primary_first_name,
       :primary_last_name,
       :primary_job_title,
       :primary_telephone_number,
       :primary_email_address,
      :businessType,
      :registrationType,
      :otherBusinesses,
      :isMainService,
      :constructionWaste,
      :onlyAMF,
      :companyName,
      :routeName,
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
      :uprn,
      :password,
      :password_confirmation,
      :accountEmail_confirmation,
      :registration_phase,
      :company_no,
      :registration_fee,
      :copy_card_fee,
      :copy_cards,
      :total_fee,
      :sign_up_mode)
  end

end
