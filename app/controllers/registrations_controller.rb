class RegistrationsController < ApplicationController

  include WorldpayHelper
  include RegistrationsHelper

  module EditStatus
    UPDATE_EXISTING_REGISTRATION_NO_CHARGE = 0
    UPDATE_EXISTING_REGISTRATION_WITH_CHARGE = 1
    CREATE_NEW_REGISTRATION = 2
  end


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
      if searchString && !searchString.empty?
        @registrations = Registration.find_all_by(searchString, searchWithin)
      else
        @registrations = []
      end
    else
      @registrations = []
      flash.now[:notice] = 'You must provide valid search parameters. Please only use letters, numbers,or any of \' . & ! %.'
    end
    session[:registration_step] = session[:registration_params] = nil
    logger.debug "index: #{ @registrations.size.to_s} items"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrations }
    end
  end

  # GET /your-registration/business-type
  def newBusinessType
    new_step_action 'businesstype'

    @registration.routeName = agency_user_signed_in? ? 'ASSISTED_DIGITAL' : 'DIGITAL'
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
        proceed_as_lower
      when 'other'
        redirect_to :newNoRegistration
      end
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newBusinessType", :status => '400'
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
        proceed_as_upper
      when 'no'
        proceed_as_lower
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
        proceed_as_lower
      when 'no'
        proceed_as_upper
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
    if params[:manualUkAddress] #we're in the manual uk address page
      @registration.addressMode = 'manual-uk'
    elsif params[:foreignAddress] #we're in the manual foreign address page
      @registration.addressMode = 'manual-foreign'
    elsif params[:autoUkAddress] #user clicked to go back to address lookup
      @registration.addressMode = nil
    end

    @registration.save
  end

  # POST /your-registration/business-details
  def updateNewBusinessDetails
    setup_registration 'businessdetails'

    if params[:addressSelector]  #user selected an address from drop-down list
      @selected_address = Address.find(params[:addressSelector])
      @selected_address ? copyAddressToSession :  logger.error("Couldn't match address #{params[:addressSelector]}")

    end

    if params[:findAddress] #user clicked on Find Address button

      @registration.addressMode = 'address-results'
      @registration.postcode = params[:registration][:postcode]
      begin
        @address_match_list = Address.find(:all, :params => {:postcode => params[:registration][:postcode]})
        logger.debug @address_match_list.size.to_s
      rescue Errno::ECONNREFUSED
        logger.error 'ERROR: Address Lookup Not running, or not Found'
      rescue ActiveResource::ServerError
        logger.error 'ERROR: ActiveResource Server error!'
      end
      render 'newBusinessDetails', status: '200'
    elsif @registration.valid?
      redirect_to :newContact
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render 'newBusinessDetails', :status => '400'
    end
  end

  # GET /your-registration/contact-details
  def newContactDetails
    new_step_action 'contactdetails'
  end

  # POST /your-registration/contact-details
  def updateNewContactDetails
    setup_registration 'contactdetails'

    # TODO Check why this is here with Fred. Was in Upper Tier
    # version of update contact details but don't see how you
    # get to this post and need to check for findAddress
    # if params[:findAddress]
    #   render "newBusinessDetails" and return
    # end
    if @registration.valid?
      if @registration.tier.eql? 'LOWER'
        redirect_to :newConfirmation
      else
        redirect_to :registration_key_people
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

  # POST /your-registration/registration-type
  def updateNewRegistrationType
    setup_registration 'registrationtype'
    if @registration.valid?
      redirect_to :newBusinessDetails
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

    @registration.convictions_check_indicates_suspect = true # TODO call convictions service with correct parameters
    @registration.criminally_suspect = @registration.convictions_check_indicates_suspect or @registration.declaredConvictions == 'yes'

    @registration.save

    if @registration.valid?
      if @registration.declaredConvictions == 'yes'
        redirect_to :newRelevantPeople
      else
        redirect_to :newConfirmation
      end
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newRelevantConvictions", :status => '400'
    end
  end

  # GET /your-registration/confirmation
  def newConfirmation
    new_step_action 'confirmation'

    case session[:edit_process]
    when 're-create'
    when 'edit'
      unless session[:edit_status] #haven't determined edit status yet, so do it now
        original_registration = Registration[ session[:original_registration_id] ]
        session[:edit_status] =  compare_registrations(@registration, original_registration )
      end

    when 'renewal'
      # update_registration session[:edit_process]
    else # new registration, do nothing
    end

    logger.debug "edit_process = #{ session[:edit_process]}"
    logger.debug "edit_status = #{ session[:edit_status]}"
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

  def new_step_action current_step

    if current_step.eql? Registration::FIRST_STEP
      @registration = Registration.create
      session[:registration_id]= @registration.id
      logger.debug "creating new registration #{@registration.id}"
      m = Metadata.create
      @registration.metaData.add m
    else
      @registration = Registration[ session[:registration_id]]
      logger.debug "retireving registration #{@registration.id}"
      m = Metadata.create
    end

    logger.debug "reg: #{@registration.id}  #{@registration.to_json}"

    if  session[:registration_progress].eql? 'IN_EDIT'
    end

    # TODO by setting the step here this should work better with forward and back buttons and urls
    # but this might have changed the behaviour
    @registration.current_step = current_step
    @registration.save
    logger.debug "new step action: #{current_step}"
    logger.debug "curret step: #{ @registration.current_step}"
    # Pass in current page to check previous page is valid
    # TODO had to comment this out for now because causing problems but will probably need to reinstate
    # check_steps_are_valid_up_until_current current_step

    #    if (session[:registration_id])
    #      #TODO show better page - the user should not be able to return to these pages after the registration has been saved
    #      renderNotFound
    #    end
  end

  def setup_registration current_step, no_update=false

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

  def proceed_as_upper
    @registration.tier = 'UPPER'
    @registration.save
    redirect_to action: 'newRegistrationType'
  end

  def proceed_as_lower
    @registration.tier = 'LOWER'
    @registration.save
    redirect_to action: 'newBusinessDetails'
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
      @registrations = Registration.find_by_email(tmpUser.email).sort_by { |r| r.date_registered}
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
    renderNotFound and  return unless session[:registration_uuid]
    @registration = Registration.find_by_id( session[:registration_uuid])
    redirect_to registrations_path and return if @registration.empty?

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
      renderNotFound and  return
    end
    # @registrations = Registration.find(:all, :params => {:ac => @user.email})
    @registrations = Registration.find_by_email(@user.email)

    unless @registrations.empty?
      @sorted = @registrations.sort_by { |r| r.date_registered}.reverse!
      @registration = @sorted.first
      @owe_money = owe_money? @registration
      @tell_waste_carrier_they_are_pending_convictions_check = declared_convictions? @registration
      session[:registration_uuid] = @registration.uuid
    else
      renderNotFound and return
    end
    #render the confirmed page
  end

  def declared_convictions? registration
    registration.declaredConvictions == 'yes'
  end

  def print_confirmed
    @registration = Registration.find_by_id(session[:registration_uuid])
    if @registration.empty?
      renderNotFound and return
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
    @registration = Registration[params[:id]]
    logger.debug "finish: #{@registration.attributes.to_s}"
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
    Rails.logger.debug "registration edit for: #{params[:id]}"
    @registration = Registration.find_by_id(params[:id])
    # let's keep track of the original registration before any edits have been done
    # the we can use it to compare it with the edited one.
    session[:original_registration_id] = Registration.find_by_id(params[:id]).id
    authorize! :update, @registration

    session[:registration_id] = @registration.id
    session[:registration_uuid] = @registration.uuid
    session[:edit_process] =  params[:edit_process]

    redirect_to :newConfirmation
  end

  def ncccedit
    logger.debug  "nccedit looking for: #{params[:id]}"
    @registration = Registration.find_by_id(session[:registration_uuid])
    logger.debug  "registration found@ #{@registration['id']}"
    @registration.routeName = @registration.metaData.first.route
    session[:registration_id] = @registration.id
    session[:registration_uuid] = @registration.uuid
    authorize! :update, @registration
  end

  def paymentstatus
    @registration = Registration.find_by_id(params[:id])
    if @registration.nil?
      renderNotFound
      return
    else
      @registration.routeName = @registration.metaData.first.route
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
    @registration.save
  end

  def updateNewSignup
    setup_registration 'signup'

    # Prepopulate Email field/Set registration account
    if user_signed_in?
      logger.debug 'User already signed in using current email: ' + current_user.email
      @registration.accountEmail = current_user.email
    elsif agency_user_signed_in?
      logger.debug 'Agency User already signed in using current email: ' + current_agency_user.email
      @registration.accountEmail = current_agency_user.email
    end

    @registration.sign_up_mode = @registration.initialize_sign_up_mode(@registration.accountEmail, (user_signed_in? || agency_user_signed_in?))
    @registration.save

    if @registration.valid?
      logger.info 'Registration is valid so far, go to next page'
      if @registration.sign_up_mode == 'sign_up'
        logger.debug "The registration's sign_up_mode is sign_up: Creating, saving and signing in user " + @registration.accountEmail
        @user = User.new
        @user.email = @registration.accountEmail
        @user.password = @registration.password
        logger.debug "About to save the new user."
        # Don't send the confirmation email when the user gets saved.
        @user.skip_confirmation_notification!
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

      logger.debug "edit process: #{session[:edit_process]}"
      case session[:edit_process]
      when 're-create'
      when 'edit'
        original_registration = Registration[ session[:original_registration_id] ]
        session[:edit_status] = compare_registrations(@registration, original_registration )
        if session[:edit_status].eql? EditStatus::CREATE_NEW_REGISTRATION
          save_registration
        else
          update_registration session[:edit_process]
          redirect_to print_confirmed_path and return
        end
      when 'renewal'
        update_registration session[:edit_process]
      else # new registration
        save_registration
      end



      session[:registration_id] = @registration.id
      session[:registration_step] = session[:registration_params] = nil

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
            send_confirm_email @registration
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




  #PUT...
  def ncccupdate
    @registration = Registration.find_by_id(params[:id])
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
          @registration.metaData.first.update(status: 'REVOKED')
          @registration.save
          @registration.commit
          logger.debug "uuid: #{@registration.uuid}"

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
        @registration.metaData.first.update(status: 'ACTIVE')
        logger.debug "COMMIT line: #{__LINE__}"
        @registration.commit
        logger.debug "uuid: #{@registration.uuid}"
        redirect_to ncccedit_path(:note => I18n.t('registrations.form.reg_unrevoked'))
      else
        renderAccessDenied
      end
    else
      logger.info 'About to Update Registration'
      if agency_user_signed_in?
        # Merge param information with registration from DB
        @registration.update_attributes(updatedParameters(@registration.metaData.first, params[:registration]))
      else
        @registration.update_attributes(params[:registration])
      end
      # Set routeName from DB before validation to ensure correct validation for registration type, e.g. ASSITED_DIGITAL or DIGITAL
      @registration.routeName = @registration.metaData.first.route
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
    @registration = Registration.find_by_id(params[:id])
    deletedCompany = @registration.companyName
    authorize! :update, @registration
    @registration.metaData.status = 'INACTIVE'
    @registration.save!

    respond_to do |format|
      format.html { redirect_to userRegistrations_path(current_user.id, :note => 'Deleted ' + deletedCompany) }
      format.json { head :no_content }
    end
  end

  def confirmDelete
    @registration = Registration.find_by_id(params[:id])
    authorize! :update, @registration
  end

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



  def calculate_fees(fee_type = 'new')

    case fee_type
    when 'new'
      @registration.registration_fee = Rails.configuration.fee_registration
    when 'renewal'
      @registration.registration_fee = Rails.configuration.fee_renewal
    when 'edit'
      @registration.registration_fee = Rails.configuration.fee_reg_type_change
    else
      @registration.registration_fee = Rails.configuration.fee_registration
    end


    @registration.copy_card_fee = @registration.copy_cards.to_i * Rails.configuration.fee_copycard
    @registration.total_fee =  @registration.registration_fee + @registration.copy_card_fee
    @registration.save
  end

  # GET upper-registrations/payment
  def newPayment
    new_step_action 'payment'
    if !@registration.copy_cards
      @registration.copy_cards = 0
    end
    logger.debug " my order: #{@registration.finance_details.first.orders.first.attributes.to_s}"

    if  (session[:edit_status].eql? EditStatus::UPDATE_EXISTING_REGISTRATION_WITH_CHARGE)
      calculate_fees('edit')
    elsif session[:edit_process].eql? 'renewal'
      calculate_fees('renewal')
    else
      calculate_fees
    end

    @order  ||= Order.new
  end

  # POST upper-registrations/payment
  def updateNewPayment
    setup_registration 'payment'

    if  (session[:edit_status].eql? EditStatus::UPDATE_EXISTING_REGISTRATION_WITH_CHARGE) ||
        (session[:edit_status].eql? EditStatus::CREATE_NEW_REGISTRATION) ||
        (session[:edit_process].eql? 'renewal')
      logger.debug " my order: #{@registration.finance_details.first.orders.first.attributes.to_s}"
    end

    # Determine what kind of payment selected and redirect to other action if required
    # if params[:offline_next] == I18n.t('registrations.form.pay_offline_button_label')
    #   @order = prepare_payment(false)
    # else
    #   @order = prepare_payment(true)
    # end

    @order = (params[:offline_next] == I18n.t('registrations.form.pay_offline_button_label'))  ? prepare_payment(false) :  prepare_payment(true)
    @order.amountType = Order.getPositiveType
    logger.debug "my order: #{ @order.attributes.to_s}"


    if @order.valid?
      logger.info "Saving the order"
      # if @order.save! @registration.uuid

      if @order.commit @registration.uuid
        # order saved successfully
      else
        # error updating services
        logger.warn 'The order was not saved to services.'
        render 'newPayment', :status => '400'
        return
      end
    else
      #We should hardly get into here given we constructed the order just above...
      logger.warn 'The new Order is invalid: ' + @order.errors.full_messages.to_s
      # Replaced flash message with render instead of redirect, so that error messages are retained.
      #flash[:notice] = 'The order is invalid!'
      render 'newPayment'
      return
    end

    logger.info "About to redirect to Worldpay/Offline payment - if the registration is valid."
    if @registration.valid?

      if params[:offline_next] == I18n.t('registrations.form.pay_offline_button_label')
        logger.info "The registration is valid - redirecting to Offline payment page..."
        redirect_to newOfflinePayment_path(:orderCode => @order.orderCode )
      else
        logger.info "The registration is valid - redirecting to Worldpay..."
        redirect_to_worldpay(@registration, @order)
      end
      return
    else
      logger.error "The registration is not valid! " + @registration.to_s
      render 'newPayment', :status => '400'
    end
  end

  #We should not use this as part of updating the payment page.
  #We should rather update the existing order and set the payment method and number of copycards.
  def prepareOrder (useWorldPay = true)
    reg = Registration.find_by_id(session[:registration_uuid])

    #TODO have a current_order method on the registration
    ord = reg.finance_details.first.orders.first

    @order = Order.create

    if useWorldPay
      @order = updateOrderForWorldpay(@order)
    else
      @order = updateOrderForOffline(@order)
    end


    # Ensure Order Id of newly created order remains the same
    # TODO: Fix later as assumed orderId of first order?
    @order.orderId = ord.orderId

    # Get a orderItem object
    ordItem = ord.order_items.first

    isInitialRegistration = true
    if isInitialRegistration
      # Add order item for Initial registration

      # Create Order Item
      orderItem = OrderItem.new
      orderItem.amount = Rails.configuration.fee_registration
      orderItem.currency = 'GBP'
      orderItem.description = 'Initial Registration'
      orderItem.reference = 'Reg: ' + @registration.regIdentifier
      orderItem.save

      @order.order_items.add orderItem
    end

    if @registration.copy_cards.to_i > 0
      # Add additional order items for copy card amount

      # Create Order Item
      orderItem = OrderItem.new
      orderItem.amount = @registration.copy_cards.to_i * Rails.configuration.fee_copycard
      orderItem.currency = 'GBP'
      orderItem.description = @registration.copy_cards.to_s + 'x Copy Cards'
      orderItem.reference = 'Reg: ' + @registration.regIdentifier
      orderItem.save

      @order.order_items.add orderItem
    end

    @order
  end

  def updateOrderForWorldpay myOrder

    now = Time.now.utc.xmlschema
    myOrder.paymentMethod = 'ONLINE'
    myOrder.orderCode = Time.now.to_i.to_s
    myOrder.merchantId = worldpay_merchant_code
    myOrder.totalAmount = @registration.total_fee
    myOrder.currency = 'GBP'
    myOrder.worldPayStatus = 'IN_PROGRESS'
    myOrder.description = 'Updated registrations PRIOR to WP'
    myOrder.dateCreated = now
    myOrder.dateLastUpdated = now
    myOrder.updatedByUser = @registration.accountEmail
    myOrder
  end

  def updateOrderForOffline myOrder

    now = Time.now.utc.xmlschema
    myOrder.paymentMethod = 'OFFLINE'
    myOrder.orderCode = Time.now.to_i.to_s
    myOrder.merchantId = 'n/a'
    myOrder.totalAmount = @registration.total_fee
    myOrder.currency = 'GBP'
    myOrder.worldPayStatus = 'n/a'
    myOrder.description = 'Updated registrations PRIOR to WP'
    myOrder.dateCreated = now
    myOrder.dateLastUpdated = now
    myOrder.updatedByUser = @registration.accountEmail
    myOrder
  end

  ######################################

  def prepareOfflinePayment
    #setup_registration 'payment'
    calculate_fees
    order = prepareOrder false
    order
  end

  def prepareOnlinePayment
    calculate_fees
    logger.info "copy cards: " + @registration.copy_cards.to_s
    logger.info "total fee: " + @registration.total_fee.to_s
    order = prepareOrder true
    order
  end

  def prepare_payment(online = true)
    order = prepareOrder(online)
    order
  end

  def newOfflinePayment
    @registration = Registration.find_by_id(session[:registration_uuid])
    # Get the order just made from the order code param
    @order = @registration.getOrder(params[:orderCode])
  end

  def updateNewOfflinePayment
    @registration = Registration[session[:registration_id]]

    if @registration.user.confirmed?
      redirect_to print_confirmed_path
    else
      send_confirm_email @registration
      redirect_to pending_path
    end
  end

  private

  def owe_money? registration
    registration.upper? and !registration.paid_in_full?
  end


  # Saves a new Registration object from to the Java Service
  #
  # @param none
  # @return none
  def save_registration
    if @registration.valid?
      logger.debug "The registration is all valid. About to save the registration..."
      @registration.expires_on = (Date.current + 3.years).to_s
      @registration.save
      logger.debug "reg: #{@registration.attributes.to_s}"
      session[:registration_uuid] = @registration.commit
      if agency_user_signed_in?
        @registration.accessCode = @registration.generate_random_access_code
        @registration.save
        logger.debug "accessCode: #{@registration.accessCode }"
      end
      # The user is signed in at this stage if he activated his e-mail/account (for a previous registration)
      # Assisted Digital registrations (made by the signed in agency user) do not need verification either.
      if agency_user_signed_in? || user_signed_in?
        @registration.activate!
      end
      @registration.save
      session[:registration_id] = @registration.id
      logger.debug "The registration has been saved. About to send e-mail..."
      if user_signed_in?
        RegistrationMailer.welcome_email(@user, @registration).deliver
      end
      logger.debug "registration e-mail has been sent."
    else
      logger.error "GGG - The registration is NOT valid!"
    end
  end

  # Updates an existing Registration object  to the Java Service
  #
  # @param edit_process [String] whether the object is updated as part of a
  # renewal, re-registration  or  edit
  # @return none
  def update_registration(edit_process)
    if @registration.valid?
      logger.debug "The registration expires on #{@registration.expires_on}"
      if edit_process.eql? 'renewal'
        expiry_date = DateTime.parse(@registration.expires_on) + 3.years
      else
        #making sure date format is correct
        expiry_date = Registration.convert_date(@registration.expires_on)
      end
      @registration.expires_on = expiry_date.to_s

      @registration.save
      logger.debug "reg: #{@registration.attributes.to_s}"
      if (@registration.save!)
        if agency_user_signed_in?
          @registration.accessCode = @registration.generate_random_access_code
          @registration.save
          logger.debug "accessCode: #{@registration.accessCode }"
        end
        logger.debug "The registration has been saved. About to send e-mail..."
        if user_signed_in?
          RegistrationMailer.welcome_email(@user, @registration).deliver
        end
        logger.debug "registration e-mail has been sent."
      else #update failed
      end
    else   logger.error "GGG - The registration is NOT valid!"
    end
  end


  def compare_registrations(edited_reg, original_reg)
    res =   EditStatus::UPDATE_EXISTING_REGISTRATION_NO_CHARGE

    if (edited_reg.key_people.size  > original_reg.key_people.size) ||
        (edited_reg.company_no != original_reg.company_no)
      edited_reg.total_fee = Rails.configuration.fee_registration
      res =   EditStatus::CREATE_NEW_REGISTRATION
    end


    if edited_reg.registrationType != original_reg.registrationType
      edited_reg.total_fee = Rails.configuration.fee_reg_type_change
      res =   EditStatus::UPDATE_EXISTING_REGISTRATION_WITH_CHARGE
    end

    logger.debug "compare_registrations: #{res}"
    res

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

  private :save_registration, :update_registration


end
