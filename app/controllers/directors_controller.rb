class DirectorsController < ApplicationController

  # GET /your-registration/directors
  def newDirectorDetails
    new_step_action 'directors'

    # Set route name based on agency paramenter
    @registration.routeName = 'DIGITAL'
    if !params[:agency].nil?
      @registration.routeName = 'ASSISTED_DIGITAL'
      logger.info 'Set route as Assisted Digital: ' + @registration.routeName
    end
  end

  # POST /your-registration/directors
  def updateNewDirectorDetails
    setup_registration 'directors'

    if @registration.valid?
      logger.info 'Registration is valid so far, go to next page'
      redirect_to :upper_payment
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "newDirectorDetails", :status => '400'
    end
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

end