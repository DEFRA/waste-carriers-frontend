class RegistrationsController < ApplicationController

  include WorldpayHelper

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
    if validate_search_parameters?(searchString,searchWithin)
      if searchString != nil && !searchString.empty?
        @registrations = Registration.find(:all, :params => {:q => searchString, :searchWithin => searchWithin})
      else
        @registrations = []
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
    new_step_action 'businesstype', true

    # Set route name based on agency paramenter
    @registration.routeName = 'DIGITAL'
    if !params[:agency].nil?
      @registration.routeName = 'ASSISTED_DIGITAL'
      logger.info 'Set route as Assisted Digital: ' + @registration.routeName
    end
  end

  # POST /your-registration/business-type
  def updateNewBusinessType
    setup_registration 'businesstype'


    if @registration.valid?
      logger.info 'Registration is valid so far, go to next page'
      # TODO set steps

      case @registration.businessType
      when 'soleTrader', 'partnership', 'limitedCompany', 'publicBody'
        redirect_to :newOtherBusinesses
      when 'charity', 'authority'
        redirect_to :newBusinessDetails
      when 'other'
        redirect_to :newNoRegistration
      end
    else
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
    else
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
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newServiceProvided", :status => '400'
    end
  end

  # GET /your-registration/construction-demolition
  def newConstructionDemolition
    new_step_action 'constructiondemolition'
  end

  # POST /your-registration/construction-demolition
  def updateNewConstructionDemolition
    setup_registration 'constructiondemolition'

    if @registration.valid?
      # TODO this is where you need to make the choice and update the steps
      case @registration.constructionWaste
      when 'yes'
        redirect_to :newRegistrationType
      when 'no'
        redirect_to :newBusinessDetails
      end
    else
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
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newOnlyDealWith", :status => '400'
    end
  end


  # GET /your-registration/business-details
  def newBusinessDetails
    new_step_action 'businessdetails'
  end

  # POST /your-registration/business-details
  def updateNewBusinessDetails
    setup_registration 'businessdetails'

    if params[:addressSelector]  #user selected an address from drop-down list
      @selected_address = Address.find(params[:addressSelector])
      @selected_address ? copyAddressToSession :  logger.error("Couldn't match address #{params[:addressSelector]}")

    end

    if params[:findAddress] #user clicked on Find Address button

      @registration.postcode = params[:registration][:postcode]
      begin
        @address_match_list = Address.find(:all, :params => {:postcode => params[:registration][:postcode]})
        logger.debug @address_match_list.size.to_s
      rescue Errno::ECONNREFUSED
        logger.error 'ERROR: Address Lookup Not running, or not Found'
      rescue ActiveResource::ServerError
        logger.error 'ERROR: ActiveResource Server error!'
      end
      render "newBusinessDetails", status: '200'

    elsif @registration.valid?
      next_step = case @registration.tier
      when 'UPPER'
        :newUpperBusinessDetails
      when 'LOWER'
        :newContact
      end
      redirect_to next_step
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newBusinessDetails", :status => '400'
    end
  end

  # GET /your-registration/contact-details
  def newContactDetails
    new_step_action 'contactdetails'
  end

  # POST /your-registration/contact-details
  def updateNewContactDetails
    setup_registration 'contactdetails'

    if @registration.valid?
      redirect_to :newConfirmation
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newContactDetails", :status => '400'
    end
  end

  # GET /your-registration/registration-type
  def newRegistrationType
    new_step_action 'registrationtype'
  end

  # POST /your-registration/registration-type
  def updateNewRegistrationType
    setup_registration 'registrationtype'
    if @registration.valid?
      redirect_to :newUpperBusinessDetails

    else
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
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newConfirmation", :status => '400'
    end
  end

  # GET /registrations/data-protection
  def dataProtection
    # Renders static data proctection page
  end

  def new_step_action current_step, this_is_first_step=false
    # session[:registration_params] ||= {}
    # session[:registration_params].deep_merge!(registration_params) if params[:registration]
    # @registration = Registration.new(session[:registration_params])

    if this_is_first_step
      @registration = Registration.create
      session[:registration_id]= @registration.id
    else
      @registration = Registration[ session[:registration_id]]
    end

    logger.debug "reg: #{@registration.to_json}"

    # TODO by setting the step here this should work better with forward and back buttons and urls
    # but this might have changed the behaviour
    @registration.current_step = current_step
    # Pass in current page to check previous page is valid
    # TODO had to comment this out for now because causing problems but will probably need to reinstate
    # check_steps_are_valid_up_until_current current_step
  end

  def setup_registration current_step, no_update=false
    # session[:registration_params] ||= {}
    # session[:registration_params].deep_merge!(registration_params) if params[:registration]
    # @registration= Registration.new(session[:registration_params])

    @registration = Registration[ session[:registration_id]]
    @registration.add( params[:registration] ) unless no_update
    @registration.save
    logger.debug  @registration.attributes.to_s

    @registration.current_step = current_step
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
      renderAccessDenied
    elsif current_user.email != tmpUser.email
      renderAccessDenied
    else
      # Search for users registrations
      # @registrations = Registration.find(:all, :params => {:ac => tmpUser.email}).sort_by { |r| r.date_registered}
      @registrations = Registration.find(accountEmail: tmpUser.email)
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
        sign_out        # Performs a signout action on the current user
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

    if @registrations.any?
      @sorted = @registrations.sort_by { |r| r.date_registered}.reverse!
      @registration = @sorted.first
      @owe_money = owe_money? @registration
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
      #TODO - Print view layout?
      render
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
    authorize! :update, @registration
  end

  def paymentstatus
    @registration = Registration.find(:one, :from => "/registrations/"+params[:id]+".json")
    @registration.routeName = @registration.metaData.route
    authorize! :update, @registration
  end

  def check_steps_are_valid_up_until_current current_step
    if !@registration.steps_valid?(current_step)
      redirect_to_failed_page(@registration.current_step)
    else
      logger.debug 'Previous pages are valid'
    end
  end


  def copyAddressToSession

    @registration = Registration[ session[:registration_id]]

    @registration.houseNumber = @selected_address.lines[0] if @selected_address.lines[0]
    @registration.streetLine1 = @selected_address.lines[1] if @selected_address.lines[1]
    @registration.streetLine2 = @selected_address.lines[2] if @selected_address.lines[2]
    @registration.streetLine3 = @selected_address.lines[3] if @selected_address.lines[3]
    @registration.townCity = @selected_address.town  if @selected_address.town
    @registration.postcode = @selected_address.postcode  if @selected_address.postcode

    @registration.save

  end


  def newSignup
    new_step_action 'signup'

    Rails.logger.debug @registration.to_json

    @registration.accountEmail = if user_signed_in?
      current_user.email
    elsif agency_user_signed_in?
      current_agency_user.email
    else
      @registration.contactEmail
    end

    # Get signup mode
    @registration.sign_up_mode = @registration.initialize_sign_up_mode(@registration.accountEmail, (user_signed_in? || agency_user_signed_in?))
    logger.info 'registration mode: ' + @registration.sign_up_mode
  end

  def updateNewSignup
    setup_registration 'signup', true

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

          @registration.accountEmail = if user_signed_in?
            current_user.email
          elsif agency_user_signed_in?
            current_agency_user.email
          end

          @user = User.find_by_email(@registration.accountEmail)
        end
      end

      logger.debug "Now asking whether registration is all valid"
      if @registration.valid?
        logger.debug "The registration is all valid. About to save the registration..."
        @registration.expires_on = Date.current + 3.years
        @registration.save
        # @registration.save!
        logger.debug "reg: #{@registration.attributes.to_s}"
        commit_to_java_api
        logger.info 'Perform an additional save, to set the Route Name in metadata'
=begin
        logger.info 'routeName = ' + @registration.routeName
        # @registration.metaData.route = @registration.routeName
        if agency_user_signed_in?
          @registration.accessCode = @registration.generate_random_access_code
        end
=end

        # The user is signed in at this stage if he activated his e-mail/account (for a previous registration)
        # Assisted Digital registrations (made by the signed in agency user) do not need verification either.
        if agency_user_signed_in? || user_signed_in?
          @registration.activate!
        end
        @registration.save!
        # session[:registration_id] = @registration.id
        logger.debug "The registration has been saved. About to send e-mail..."
        if user_signed_in?
          RegistrationMailer.welcome_email(@user, @registration).deliver
        end
        logger.debug "registration e-mail has been sent."
      else
        logger.error "GGG - The registration is NOT valid!"
      end

      session[:registration_id] = @registration.id
      session[:registration_step] = session[:registration_params] = nil


      # if !@registration.id.nil?
      unless @registration.status.eql? 'ACTIVE'


        ## Account not yet activated for new user. Cannot redirect to the finish URL
        if agency_user_signed_in? || user_signed_in?
          next_step = case @registration.tier
          when 'LOWER'
            finish_url(:id => @registration.id)
          when 'UPPER'
            :upper_payment
          end

          redirect_to next_step
        else
          next_step = case @registration.tier
          when 'LOWER'
            pending_url
          when 'UPPER'
            :upper_payment
          end
          redirect_to next_step
        end
      else
        # Registration Id not found, must have done something wrong
        logger.info 'Registration Id not found, must have done something wrong'
        render :file => "/public/session_expired.html", :status => 400
      end
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newSignup", :status => '400'
    end
  end



  def pending
    @registration = Registration[session[:registration_id]]
    @owe_money = owe_money? @registration
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

        if @registration.valid?
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
      if @registration.valid?
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
    if validate_public_search_parameters?(searchString,"any",distance, postcode)
      if searchString != nil && !searchString.empty?
        @registrations = Registration.find(:all, :params => {:q => searchString, :searchWithin => 'companyName', :distance => distance, :activeOnly => 'true', :postcode => postcode, :excludeRegId => 'true' })
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

  # GET your-registration/upper-tier-contact-details
  def newUpperBusinessDetails
    new_step_action 'upper_business_details'
  end

  # POST your-registration/upper-tier-contact-details
  def updateNewUpperBusinessDetails
    setup_registration 'upper_business_details'

    if params[:addressSelector]  #user selected an address from drop-down list
      @selected_address = Address.find(params[:addressSelector])
      if @selected_address
        copyAddressToSession
      else logger.error "Couldn't match address #{params[:addressSelector]}"
      end
    end

    if params[:findAddress] #user clicked on Find Address button

      @registration.postcode = params[:registration][:postcode]
      begin

        @address_match_list = Address.find(:all, :params => {:postcode => params[:registration][:postcode]})
        logger.debug @address_match_list.size.to_s
      rescue Errno::ECONNREFUSED
        logger.error 'ERROR: Address Lookup Not running, or not Found'
      rescue ActiveResource::ServerError
        logger.error 'ERROR: ActiveResource Server error!'
      end
      render "newUpperBusinessDetails", status: '200'


    elsif @registration.valid?
      logger.debug 'registration.valid'
      logger.debug params.keys.to_s
      redirect_to :newUpperContactDetails
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newUpperBusinessDetails", :status => '400'
    end

  end



  # GET your-registration/upper-tier-contact-details
  def newUpperContactDetails
    new_step_action 'upper_contact_details'
    logger.debug  session[:registration_params][:company_name].to_s
  end

  # POST your-registration/upper-tier-contact-details
  def updateNewUpperContactDetails
    setup_registration 'upper_contact_details'

    if params[:findAddress]
      render "newBusinessDetails"
    elsif @registration.valid?
      redirect_to :registration_directors
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newUpperContactDetails", :status => '400'
    end
  end

  # GET upper-registrations/payment
  def newPayment
    new_step_action 'payment'
    @registration.registration_fee = 154
    @registration.copy_cards = 0
    @registration.copy_card_fee = @registration.copy_cards * 5
    @registration.total_fee =  @registration.registration_fee + @registration.copy_card_fee
  end

  # POST upper-registrations/payment
  def updateNewPayment
    setup_registration 'payment'

    if @registration.valid?
      redirect_to_worldpay
    else
      render 'newPayment', :status => '400'
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
    else
      render 'newUpperSummary', :status => '400'
    end
  end
  ######################################

  def newOfflinePayment
    @registration = Registration[session[:registration_id]]
  end

  def updateNewOfflinePayment
    redirect_to :pending_payment
  end

  private

  def owe_money? registration
    registration.upper? and !registration.paid_in_full?
  end

  def commit_to_java_api
    url = "#{Rails.configuration.waste_exemplar_services_url}/registration.json"
    logger.debug url.to_s
    response = RestClient.post url,
                    @registration.attributes.to_json,
                    content_type: json,
                    accept: json

    Rails.logger.debug "response code: #{ response.code.to_s}"
    Rails.logger.debug "response body: #{ response.body.to_s}"
  end

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
