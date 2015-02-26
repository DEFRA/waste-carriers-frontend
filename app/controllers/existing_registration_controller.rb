class ExistingRegistrationController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/existing-registration
  def show
    new_step_action 'enterRegNumber'
  end

  # POST /your-registration/existing-registration
  def create
    setup_registration 'enterRegNumber'
    return unless @registration

    # Strip off leading/trailing whitespace and force to uppercase
    @registration.originalRegistrationNumber = formatIRRenewalNumber(@registration.originalRegistrationNumber)

    # Validate which type of registration applied with, legacy IR system, Lower, or Upper current system
    if @registration.valid?

      # Check current format
      if isCurrentRegistrationType @registration.originalRegistrationNumber
        # regNo matched

        # redirect to sign in page
        logger.debug "Current registration matched, Redirect to user sign in"
        redirect_to :new_user_session
        return
        # Check old format
      elsif isIRRegistrationType @registration.originalRegistrationNumber
        # legacy regNo matched

        # Call IR services to import IR registraion data
        irReg = Registration.find_by_ir_number(@registration.originalRegistrationNumber)
        if irReg
          # IR data found, merge with registration

          # Save IR registration data to session, for comparison at payment time
          session[:original_registration_id] = irReg.id

          # Access Code is one of the registration variables that should not get overriden with IR data
          # so it is saved and reapplied after the merge
          accessCode = @registration.accessCode

          # Merge params registration with registration in memory
          @registration.add( irReg.attributes )

          # re-apply accessCode
          @registration.accessCode = accessCode

          @registration.save

          logger.debug "Legacy registration matched, Redirect to smart answers"
          redirect_to :business_type
          return
        else
          # No IR data found
          @registration.errors.add(:originalRegistrationNumber, I18n.t('errors.messages.invalid_registration_number'))
        end
        # Error not matched
      else
        @registration.errors.add(:originalRegistrationNumber, I18n.t('errors.messages.invalid_registration_number'))
      end
    end

    # Error must have occured, re-render view
    render 'show', :status => '400'

  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def registration_params
    params.require(:registration).permit(
        :originalRegistrationNumber)
  end

end
