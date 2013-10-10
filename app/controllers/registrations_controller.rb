class RegistrationsController < ApplicationController
  # GET /registrations
  # GET /registrations.json
  def index
    @registrations = Registration.all
    session[:registration_step] = session[:registration_params] = nil

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrations }
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
  end

  def start
  end

  def finish
    @registration = Registration.find(params[:id])
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
      if @registration.last_step?
        @registration.save if @registration.all_valid?
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
end
