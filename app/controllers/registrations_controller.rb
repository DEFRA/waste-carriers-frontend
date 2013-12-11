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
    if validate_search_parameters?(searchString,searchWithin)
      if searchString != nil && !searchString.empty?
        @registrations = Registration.find(:all, :params => {:q => searchString, :searchWithin => searchWithin})
      else
        @registrations = []
      end
    else
      @registrations = []
      flash.now[:notice] = 'Invalid search parameters. Please only use letters, numbers,or any of \' . & ! %.'
    end
    session[:registration_step] = session[:registration_params] = nil

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrations }
    end
  #rescue ActiveResource::ServerError
  #  redirect_to registrations_path(:error => 'Server Error detected, check the log for details. Detected searching for: ' + (params[:q] || '') )
  #rescue Errno::ECONNREFUSED
  #	render :file => "/public/503.html", :status => 503
  end
  
  def validate_search_parameters?(searchString, searchWithin)
    searchString_valid = searchString == nil || !searchString.empty? && searchString.match(Registration::VALID_CHARACTERS)
    searchWithin_valid = searchWithin == nil || searchWithin.empty? || (['any','companyName','contactName','postcode'].include? searchWithin)
    searchString_valid && searchWithin_valid
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
      @registrations = Registration.find(:all, :params => {:ac => tmpUser.email})
	  respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @registrations }
      end
    end
  end

  # GET /registrations/1
  # GET /registrations/1.json
  def show
    @registration = Registration.find(params[:id])
    authorize! :read, @registration

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registration }
    end
  rescue ActiveResource::ResourceNotFound
    redirect_to registrations_path(:error => 'Could not find registration: ' + params[:id] )
  end

#  def start
#  end
  
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
  
  def privacy
    render :file => "/public/privacy.html", :status => 200
  end

  # GET /registrations/new
  # GET /registrations/new.json
#  def new
#    logger.info 'Request New Registration'
#    session[:registration_params] = {}
#    session[:registration_step] = nil
#    @registration = Registration.new(session[:registration_params])
#    @registration.current_step = session[:registration_step]
#    # Set route name based on agency paramenter
#    @registration.routeName = 'DIGITAL'
#    if !params[:agency].nil?
#      @registration.routeName = 'ASSISTED_DIGITAL'
#      logger.info 'Set route as Assisted Digital: ' + @registration.routeName
#    end
#    # Prepop businessType with value from smarter answers
#    if !params[:smarterAnswersBusiness].nil?
#      logger.info 'Smart answers pre-pop detected: ' + params[:smarterAnswersBusiness]
#      @registration.businessType = params[:smarterAnswersBusiness]
#    end
#  end

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
  
  def newBusinessDetails
    logger.info 'Request New Registration'
    #session[:registration_params] = {} # TODO Move this to the post of the smart answers before the redirect to here
    session[:registration_params] ||= {}
    @registration = Registration.new(session[:registration_params])
    
    # Set route name based on agency paramenter
    @registration.routeName = 'DIGITAL'
    if !params[:agency].nil?
      @registration.routeName = 'ASSISTED_DIGITAL'
      logger.info 'Set route as Assisted Digital: ' + @registration.routeName
    end
    # Prepop businessType with value from smarter answers
    if !params[:smarterAnswersBusiness].nil?
      logger.info 'Smart answers pre-pop detected: ' + params[:smarterAnswersBusiness]
      @registration.businessType = params[:smarterAnswersBusiness]
    end
  end
  
  def updateNewBusinessDetails
    logger.info 'updateNewBusinessDetails()'
    session[:registration_params] ||= {}
    session[:registration_params].deep_merge!(registration_params) if params[:registration]
    @registration= Registration.new(session[:registration_params])
    @registration.current_step = "business"
    
    if params[:back]
      logger.info 'Registration back request from first page'
      session[:registration_step] = nil
      if @registration.routeName == 'DIGITAL'
        if user_signed_in?
          logger.debug 'User already signed in so redirect to my account page'
          redirect_to userRegistrations_path(current_user.id)
        else
          logger.debug 'User not signed in so redirect to smarter answers'
          redirect_to :find
        end
      else
        logger.debug 'Assisted digital route detected, redirect to search page'
        redirect_to registrations_path
      end
    elsif @registration.valid?
      logger.info 'Registration is valid so far, go to next page'
      redirect_to :newContact
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newBusinessDetails", :status => '400'
      #redirect_to newBusiness_path
    end
  end
  
  def newContactDetails
    session[:registration_params] ||= {}
    session[:registration_params].deep_merge!(registration_params) if params[:registration]
    @registration = Registration.new(session[:registration_params])
    
    # Pass in current page to check previous page is valid
    if !@registration.steps_valid?("contact")
      redirect_to_failed_page(@registration.current_step)
    else
      logger.debug 'Previous pages are valid'
    end
  end
  
  def updateNewContactDetails
    logger.info 'updateNewContactDetails()'
    session[:registration_params] ||= {}
    session[:registration_params].deep_merge!(registration_params) if params[:registration]
    @registration = Registration.new(session[:registration_params])
    @registration.current_step = "contact"
    
    if params[:back]
      logger.info 'Registration back request from contact page'
      redirect_to :newBusiness
    elsif @registration.valid?
      logger.info 'Registration is valid so far, go to next page'
      redirect_to :newConfirmation
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newContactDetails", :status => '400'
    end
  end
  
  def newConfirmation
    session[:registration_params] ||= {}
    session[:registration_params].deep_merge!(registration_params) if params[:registration]
    @registration = Registration.new(session[:registration_params])
    
    # Pass in current page to check previous page is valid
    if !@registration.steps_valid?("confirmation")
      redirect_to_failed_page(@registration.current_step)
    else
      logger.debug 'Previous pages are valid'
    end
  end
  
  def updateNewConfirmation
    logger.info 'updateNewConfirmation()'
    session[:registration_params] ||= {}
    session[:registration_params].deep_merge!(registration_params) if params[:registration]
    @registration = Registration.new(session[:registration_params])
    @registration.current_step = "confirmation"
    
    if params[:back]
      logger.info 'Registration back request from confirmation page'
      redirect_to :newContact
    elsif @registration.valid?
      logger.info 'Registration is valid so far, go to next page'
      redirect_to :newSignup
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newConfirmation", :status => '400'
    end
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
    if params[:back]
      logger.info 'Registration back request from signup page'
      redirect_to :newConfirmation
    elsif @registration.valid?
      logger.info 'Registration is valid so far, go to next page'
      if @registration.sign_up_mode == 'sign_up'
        logger.debug "The registration's sign_up_mode is sign_up: Creating, saving and signing in user " + @registration.accountEmail
        @user = User.new
        @user.email = @registration.accountEmail
        @user.password = @registration.password
        logger.debug "About to save the new user."
        @user.save!
        logger.debug "User has been saved."
        sign_in @user
        logger.debug "The newly saved user has been signed in"
		  
        # Reset Signed up user to signed in status
        @registration.sign_up_mode = 'sign_in'
	    else
        logger.debug "Registration sign_up_mode is NOT sign_up. sign_up_mode = " + @registration.sign_up_mode.to_s
        if @registration.sign_up_mode == 'sign_in'
          @user = User.find_by_email(@registration.accountEmail)
          if @user.valid_password?(@registration.password)
            logger.info "The user's password is valid. Signing in user " + @user.email
            sign_in @user
          else
            logger.error "GGG ERROR - password not valid for user with e-mail = " + @registration.accountEmail
            #TODO error - should have caught the error in validation
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
        @registration.save!
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
      redirect_to finish_url(:id => @registration.id)
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newSignup", :status => '400'
    end
  end
  
  def redirect_to_failed_page(failedStep)
    logger.debug 'redirect_to_failed_page(failedStep) failedStep: ' +  failedStep
    if failedStep == "business"
      redirect_to :newBusiness
    elsif failedStep == "contact"
      redirect_to :newContact
    elsif failedStep == "confirmation"
      redirect_to :newConfirmation
    elsif failedStep == "signup"
      redirect_to :newSignup
    end
  end

  # POST /registrations
  # POST /registrations.json
#  def create
#  	session[:registration_params] ||= {}
#    session[:registration_params].deep_merge!(registration_params) if params[:registration]
#    @registration= Registration.new(session[:registration_params])
#    @registration.current_step = session[:registration_step]
#    first = @registration.first_step?
#    
#    # Log current Step
#    logger.info 'current step is: ' + @registration.current_step
#    
#    # Log persisted
#    if @registration.persisted?
#      logger.info 'persisted is true'
#    elsif !@registration.persisted?
#      logger.info 'persisted is false'
#    else
#      logger.info 'persisted is not known'
#    end
#    
#	# Log whether the user is currently logged in
#    if user_signed_in?
#      logger.info 'User Signed in ' + current_user.email
#    elsif agency_user_signed_in?
#      logger.info 'Agency User Signed in ' + current_agency_user.email
#    elsif !user_signed_in?
#      logger.info 'User NOT Signed in'
#    else
#      logger.info 'User status not known'
#    end
#    
#    #logger.info 'sign_up_mode: ' + @registration.sign_up_mode
#    
#    if params[:back]
#      @registration.previous_step
#      session[:registration_step] = @registration.current_step
#      
#      logger.info 'Navigate back to previous step'
#      
#    elsif @registration.valid?
#      if @registration.confirmation_step?
#      
#        # Prepopulate Email field/Set registration account
#        if user_signed_in? 
#          logger.debug 'User already signed in using current email: ' + current_user.email
#          @registration.accountEmail = current_user.email
#        elsif agency_user_signed_in?
#          logger.debug 'Agency User already signed in using current email: ' + current_agency_user.email
#          @registration.accountEmail = current_agency_user.email
#        else
#          logger.debug 'User NOT signed in using contact email: ' + @registration.contactEmail
#          @registration.accountEmail = @registration.contactEmail
#        end
#        
#        # Get signup mode
#        @registration.sign_up_mode = @registration.initialize_sign_up_mode(@registration.accountEmail, (user_signed_in? || agency_user_signed_in?))
#        logger.debug 'registration mode: ' + @registration.sign_up_mode
#        
#      end
#      
#      logger.info 'Registration is potentially valid...'
#      
#      if @registration.last_step?
#        if @registration.sign_up_mode == 'sign_up'
#          logger.debug "The registration's sign_up_mode is sign_up: Creating, saving and signing in user " + @registration.accountEmail
#          @user = User.new
#          @user.email = @registration.accountEmail
#          @user.password = @registration.password
#          logger.debug "About to save the new user."
#          @user.save!
#          logger.debug "User has been saved."
#          sign_in @user
#          logger.debug "The newly saved user has been signed in"
#          
#          # Reset Signed up user to signed in status
#          @registration.sign_up_mode = 'sign_in'
#        else
#          logger.debug "Registration sign_up_mode is NOT sign_up. sign_up_mode = " + @registration.sign_up_mode
#          if @registration.sign_up_mode == 'sign_in'
#          	@user = User.find_by_email(@registration.accountEmail)
#            if @user.valid_password?(@registration.password)
#              logger.info "The user's password is valid. Signing in user " + @user.email
#              sign_in @user
#            else
#              logger.error "GGG ERROR - password not valid for user with e-mail = " + @registration.accountEmail
#              #TODO error - should have caught the error in validation
#            end
#          else
#          	logger.debug "User signed in, set account email to user email and get user"
#          	if user_signed_in?
#		      @registration.accountEmail = current_user.email
#		    elsif agency_user_signed_in?
#		      @registration.accountEmail = current_agency_user.email
#		    end
#          	@user = User.find_by_email(@registration.accountEmail)
#          end
#        end
#        logger.debug "Now asking whether registration is all valid"
#        if @registration.all_valid?
#          logger.debug "The registration is all valid. About to save the registration..."
#          @registration.save!
#          logger.info 'Perform an additional save, to set the Route Name in metadata'
#          logger.info 'routeName = ' + @registration.routeName
#          @registration.metaData.route = @registration.routeName
#          if agency_user_signed_in?
#            @registration.accessCode = @registration.generate_random_access_code
#          end
#          @registration.save!
#          logger.debug "The registration has been saved. About to send e-mail..."
#          if user_signed_in?
#            RegistrationMailer.welcome_email(@user, @registration).deliver
#          end
#          logger.debug "registration e-mail has been sent."
#        else
#          logger.error "GGG - The registration is NOT valid!"
#        end
#      else
#        @registration.next_step
#      end
#      session[:registration_step] = @registration.current_step
#    end
#    if params[:back] and first
#      session[:registration_step] = nil
#      if @registration.routeName == 'DIGITAL'
#        if user_signed_in?
#          logger.debug 'User already signed in so redirect to my account page'
#          redirect_to userRegistrations_path(current_user.id)
#        else
#          logger.debug 'User not signed in so redirect to smarter answers'
#          redirect_to :find
#        end
#      else
#        logger.debug 'Assisted digital route detected, redirect to search page'
#        redirect_to registrations_path
#      end
#    elsif @registration.new_record?
#      render "new"
#    else
#      session[:registration_step] = session[:registration_params] = nil
#      redirect_to finish_url(:id => @registration.id)
#    end
#    
#  end
  

  #PUT...
  def ncccupdate
    @registration = Registration.find(params[:id])
    authorize! :update, @registration

    if params[:back]
      if agency_user_signed_in?
        logger.info 'Redirect to search page for agency users'
        redirect_to registrations_path
      else
        logger.info 'Redirect to my account page for external users'
        redirect_to userRegistrations_path(current_user.id)
      end
    elsif params[:reprint]
      logger.debug 'Redirect to Print page'
      redirect_to print_url(:id => params[:id], :reprint => params[:reprint])
    elsif params[:revoke]
      if agency_user_signed_in?
        logger.info 'Revoke action detected'
        @registration.metaData.status = "REVOKED"
        @registration.save
        redirect_to ncccedit_path(:note => I18n.t('registrations.form.reg_revoked'))
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
      @registration.update_attributes(params[:registration])
      # Set routeName from DB before validation to ensure correct validation for registration type, e.g. ASSITED_DIGITAL or DIGITAL
      @registration.routeName = @registration.metaData.route
      if @registration.all_valid?
        @registration.save
        redirect_to ncccedit_path(:note => I18n.t('registrations.form.reg_updated') )
      else
        render "ncccedit"
      end
    end
  end

  # PUT /registrations/1
  # PUT /registrations/1.json
#  def update
#    session[:registration_params] ||= {}
#    session[:registration_params].deep_merge!(params[:registration]) if params[:registration]
#    @registration = Registration.find(params[:id])
#    @registration.current_step = session[:registration_step]
#    first = @registration.first_step?
#    last = @registration.last_step?
#    if params[:back]
#      @registration.previous_step
#      session[:registration_step] = @registration.current_step
#    else
#      if @registration.valid?
#        logger.info "Performing update of registration"
#        @registration.update_attributes(session[:registration_params])
#        @registration.current_step = session[:registration_step]
#        first = @registration.first_step?
#        last = @registration.last_step?
#        if @registration.last_step?
#          @registration.save if @registration.all_valid?
#        else
#          @registration.next_step
#        end
#        session[:registration_step] = @registration.current_step
#      end
#    end
#    if params[:back] and first
#      session[:registration_step] = nil
#      logger.info "Redirected back to My account summary, also cleared registration session"
#      session[:registration_params] ||= {}
#      redirect_to userRegistrations_path(current_user.id)
#    elsif params[:back] or not (last and @registration.all_valid?)
#      render "edit"
#    else
#      session[:registration_step] = session[:registration_params] = nil
#      logger.info "This should have been a signed in user, completing an update redirecting to my account"
#      redirect_to userRegistrations_path(current_user.id)
#    end
#  end

  # DELETE /registrations/1
  # DELETE /registrations/1.json
  def destroy
    ##TODO re-introduce when needed
    renderAccessDenied
    #@registration = Registration.find(params[:id])
    #authorize! :update, @registration
    #@registration.destroy

    #respond_to do |format|
    #  format.html { redirect_to registrations_url }
    #  format.json { head :no_content }
    #end
  end
  
  def publicSearch
    distance = params[:distance]
    searchString = params[:q]
    tcp = params[:tcp]
    if validate_search_parameters?(searchString,"any")
      if searchString != nil && !searchString.empty?
        @registrations = Registration.find(:all, :params => {:q => searchString, :searchWithin => distance, :activeOnly => 'true' })
      else
        @registrations = []
      end
    else
      @registrations = []
      flash.now[:notice] = 'Invalid search parameters. Please only use letters, numbers,or any of \' . & ! %.'
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

private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def registration_params
    params.require(:registration).permit(
      :businessType,
      :companyName,
      :routeName,
      :houseNumber,
      :streetLine1,
      :streetLine2,
      :townCity,
      :postcode,
      :postcodeSearch,
      :title,
      :otherTitle,
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
      :sign_up_mode)
  end 
   
end
