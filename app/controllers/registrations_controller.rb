class RegistrationsController < ApplicationController

  #We require authentication (and authorisation) largely only for editing registrations,
  #and for viewing the finished/completed registration.

  before_filter :authenticate_admin_request!

  before_filter :authenticate_external_user!, :only => [:update, :ncccedit, :ncccupdate, :destroy, :finish]

  # GET /registrations
  # GET /registrations.json
  def index
    @registrations = Registration.find(:all, :params => {:q => params[:q], :searchWithin => params[:searchWithin]})
    session[:registration_step] = session[:registration_params] = nil

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrations }
    end
  rescue ActiveResource::ServerError
    redirect_to registrations_path(:error => 'Server Error detected, check the log for details. Detected searching for: ' + params[:q] )
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
  	@registration = Registration.find(params[:id])
  	if params[:finish]
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
    session[:registration_params] ||= {}
    @registration = Registration.new(session[:registration_params])
    @registration.current_step = session[:registration_step]
  end

  # GET /registrations/1/edit
  def edit
    session[:registration_params] ||= {}
    @registration = Registration.find(params[:id])
    @registration.update_attributes(session[:registration_params])
    @registration.current_step = session[:registration_step]
  end
  
  def ncccedit
    @registration = Registration.find(params[:id])
  end

  # POST /registrations
  # POST /registrations.json
  def create
    session[:registration_params].deep_merge!(params[:registration]) if params[:registration]
    @registration= Registration.new(session[:registration_params])
    @registration.current_step = session[:registration_step]
    first = @registration.first_step?
    if params[:back]
      @registration.previous_step
      session[:registration_step] = @registration.current_step
    elsif @registration.valid?
      if @registration.confirmation_step?
        #@registration.initialize_sign_up_mode
      end
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
        else
          logger.debug "Registration sign_up_mode is NOT sign_up. sign_up_mode = " + @registration.sign_up_mode
          @user = User.find_by_email(@registration.accountEmail)
          if @user.valid_password?(@registration.password)
            logger.info "The user's password is valid. Signing in user " + @user.email
            sign_in @user
          else
            logger.error "GGG ERROR - password not valid for user with e-mail = " + @registration.accountEmail
            #TODO error - should have caught the error in validation
          end
        end
        #Note: We are resetting the sign_up_mode here to avoid the error message that the e-mail is already taken
        @registration.sign_up_mode = 'sign_in'
        logger.debug "Now asking whether registration is all valid"
        if @registration.all_valid?
          logger.debug "The registration is all valid. About to save the registration..."
          @registration.save!
          logger.debug "The registration has been saved. About to send e-mail..."
          RegistrationMailer.welcome_email(@user).deliver
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
  
  def ncccupdate
    if params[:back]
      redirect_to registrations_path
    else
      @registration = Registration.find(params[:id])
      @registration.update_attributes(params[:registration])
      if @registration.all_valid?
        @registration.save
        redirect_to registrations_path
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
    @registration.update_attributes(session[:registration_params])
    @registration.current_step = session[:registration_step]
    first = @registration.first_step?
    last = @registration.last_step?
    if params[:back]
      @registration.previous_step
      session[:registration_step] = @registration.current_step
    elsif @registration.valid?
      if @registration.last_step?
        @registration.save if @registration.all_valid?
      else
        @registration.next_step
      end
      session[:registration_step] = @registration.current_step
    end
    if params[:back] and first
      session[:registration_step] = nil
      redirect_to registrations_path
    elsif params[:back] or not (last and @registration.all_valid?)
      render "edit"
    else
      session[:registration_step] = session[:registration_params] = nil
      redirect_to registrations_path
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
    if !is_admin_request!
      authenticate_user!
    end
  end

end
