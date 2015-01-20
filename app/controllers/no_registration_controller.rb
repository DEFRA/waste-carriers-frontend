class NoRegistrationController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/no-registration
  def show
    new_step_action 'noregistration'
  end

end
