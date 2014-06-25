class TemplatesController < ApplicationController

  # GET /templates/form
  def formExample
    new_step_action 'formExample'
  end

  # POST /templates/form
  def updateFormExample
    setup_registration 'formExample'

    if @registration.valid?
      logger.info 'Registration is valid so far, go to next page'
      redirect_to :formExample
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render "formExample", :status => '400'
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