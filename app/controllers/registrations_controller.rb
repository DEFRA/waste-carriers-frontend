class RegistrationsController < ApplicationController

  #We require authentication (and authorisation) largely only for editing registrations,
  #and for viewing the finished/completed registration.

  before_filter :authenticate_admin_request!

  before_filter :authenticate_external_user!, :only => [:update, :ncccedit, :ncccupdate, :destroy, :finish, :print]

  # GET /registrations
  # GET /registrations.json
  def index
    @registrations = Registration.find(:all, :params => {:q => params[:q], :searchWithin => params[:searchWithin]})
    session[:registration_step] = session[:registration_params] = nil

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrations }
    end
  #rescue ActiveResource::ServerError
  #  redirect_to registrations_path(:error => 'Server Error detected, check the log for details. Detected searching for: ' + (params[:q] || '') )
  rescue Errno::ECONNREFUSED
  	render :file => "/public/503.html", :status => 503
  end
  
  def userRegistrations
    # Get user from id in url
    tmpUser = User.find_by_id(params[:id])
    # if matches current logged in user
    if tmpUser.nil? || current_user.nil?
      redirect_to registrations_path(:error => 'Access Denied: User does not exist' )
    elsif current_user.email != tmpUser.email
      redirect_to registrations_path(:error => 'Access Denied: Cannot access this page' )
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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registration }
    end
  rescue ActiveResource::ResourceNotFound
    redirect_to registrations_path(:error => 'Could not find registration: ' + params[:id] )
  end

  def start
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
  	  logger.info 'Sign user out before redirecting back to GDS site'
  	  sign_out 				# Performs a signout action on the current user
      redirect_to Rails.configuration.waste_exemplar_end_url
    elsif params[:back]
      redirect_to finish_url(:id => @registration.id)
    else
	  render :layout => 'printview'
    end
  end

  def finish
    @registration = Registration.find(params[:id])
    authorize! :read, @registration
  end

  # GET /registrations/new
  # GET /registrations/new.json
  def new
    session[:registration_params] = {}
    @registration = Registration.new(session[:registration_params])
    @registration.current_step = session[:registration_step]
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
    authorize! :update, @registration
  end

  # POST /registrations
  # POST /registrations.json
  def create
  	session[:registration_params] ||= {}
    session[:registration_params].deep_merge!(params[:registration]) if params[:registration]
    @registration= Registration.new(session[:registration_params])
    @registration.current_step = session[:registration_step]
    first = @registration.first_step?
    
    # Log current Step
    logger.info 'current step is: ' + @registration.current_step
    
    # Log persisted
    if @registration.persisted?
      logger.info 'persisted is true'
    elsif !@registration.persisted?
      logger.info 'persisted is false'
    else
      logger.info 'persisted is not known'
    end
    
	# Log whether the user is currently logged in
    if user_signed_in?
      logger.info 'User Signed in ' + current_user.email
    elsif agency_user_signed_in?
      logger.info 'Agency User Signed in ' + current_agency_user.email
    elsif !user_signed_in?
      logger.info 'User NOT Signed in'
    else
      logger.info 'User status not known'
    end
    
    #logger.info 'sign_up_mode: ' + @registration.sign_up_mode
    
    if params[:back]
      @registration.previous_step
      session[:registration_step] = @registration.current_step
      
      logger.info 'Navigate back to previous step'
      
    elsif @registration.valid?
      if @registration.confirmation_step?
      
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
      
      logger.info 'Registration is potentially valid...'
      
      if @registration.last_step?
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
          logger.debug "Registration sign_up_mode is NOT sign_up. sign_up_mode = " + @registration.sign_up_mode
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
          logger.debug "The registration has been saved. About to send e-mail..."
          RegistrationMailer.welcome_email(@user, @registration).deliver
          logger.debug "registration e-mail has been sent."
        else
          logger.error "GGG - The registration is NOT valid!"
        end
      else
        @registration.next_step
      end
      session[:registration_step] = @registration.current_step
    end
    if params[:back] and first
      session[:registration_step] = nil
      redirect_to start_path
    elsif @registration.new_record?
      render "new"
    else
      session[:registration_step] = session[:registration_params] = nil
      redirect_to finish_url(:id => @registration.id)
    end
    
  end
  

  #PUT...
  def ncccupdate
    @registration = Registration.find(params[:id])
    authorize! :update, @registration

    if params[:back]
      redirect_to registrations_path
    elsif params[:print]
      redirect_to print_url(:id => params[:id])
    elsif params[:revoke]
      logger.info 'Revoke action detected'
      #@registration = Registration.find(params[:id])
      @registration.metaData.status = "REVOKED"
      @registration.save
      redirect_to ncccedit_path(:note => "Revoke performed")
    elsif params[:unrevoke]
      logger.info 'Revoke action detected'
      #@registration = Registration.find(params[:id])
      @registration.metaData.status = "ACTIVE"
      @registration.save
      redirect_to ncccedit_path(:note => "Un-Revoke performed")
    else
      #@registration = Registration.find(params[:id])
      @registration.update_attributes(params[:registration])
      if @registration.all_valid?
        @registration.save
        redirect_to ncccedit_path(:note => "Registration updated")
      else
        render "ncccedit"
      end
    end
  end

  # PUT /registrations/1
  # PUT /registrations/1.json
  def update
    session[:registration_params] ||= {}
    session[:registration_params].deep_merge!(params[:registration]) if params[:registration]
    @registration = Registration.find(params[:id])
    @registration.current_step = session[:registration_step]
    first = @registration.first_step?
    last = @registration.last_step?
    if params[:back]
      @registration.previous_step
      session[:registration_step] = @registration.current_step
    else
      if @registration.valid?
        logger.info "Performing update of registration"
        @registration.update_attributes(session[:registration_params])
        @registration.current_step = session[:registration_step]
        first = @registration.first_step?
        last = @registration.last_step?
        if @registration.last_step?
          @registration.save if @registration.all_valid?
        else
          @registration.next_step
        end
        session[:registration_step] = @registration.current_step
      end
    end
    if params[:back] and first
      session[:registration_step] = nil
      logger.info "Redirected back to My account summary, also cleared registration session"
      session[:registration_params] ||= {}
      redirect_to userRegistrations_path(current_user.id)
    elsif params[:back] or not (last and @registration.all_valid?)
      render "edit"
    else
      session[:registration_step] = session[:registration_params] = nil
      logger.info ">>>>>>>>>>>>>>>>> Unknown Route: When did this occur"
      redirect_to registrations_path                # TODO Change this, as should not go to registrations, but not sure when this is used
    end
  end

  # DELETE /registrations/1
  # DELETE /registrations/1.json
  def destroy
    @registration = Registration.find(params[:id])
    @registration.destroy

    respond_to do |format|
      format.html { redirect_to registrations_url }
      format.json { head :no_content }
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

end
