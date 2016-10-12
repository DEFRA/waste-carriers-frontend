class ExistingRegistrationController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/:reg_uuid/existing-registration
  def show
    new_step_action 'enterRegNumber'
    return unless @registration
  end

  # POST /your-registration/existing-registration
  def create
    setup_registration 'enterRegNumber', true
    return unless @registration

    # Strip off leading/trailing whitespace and force to uppercase
    @registration.originalRegistrationNumber = formatIRRenewalNumber(registration_params[:originalRegistrationNumber])

    # Validate which type of registration applied with, legacy IR system, Lower, or Upper current system
    if @registration.valid?

      # Check current format
      if isCurrentRegistrationType(@registration.originalRegistrationNumber)
        # regNo matched

        # redirect to sign in page
        logger.debug "Current registration matched, Redirect to user sign in"
        redirect_to :new_user_session
        return
      elsif(isIRRegistrationType @registration.originalRegistrationNumber)
        # Legacy regNo matched, check old format

        # Call IR services to import IR registraion data
        ir_registration = Registration.find_by_ir_number(@registration.originalRegistrationNumber)

        if ir_registration.present?
          # IR data found, merge with registration in redis
          # Access Code and reg_uuid should not get overriden with IR data
          @registration.add(ir_registration.attributes.except(:reg_uuid, :accessCode))
          @registration.save

          logger.debug "Legacy registration matched, Redirect to smart answers"
          redirect_to(:business_type) and return
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
    render 'show', status: :bad_request

  end

  private

  def registration_params
    params.require(:registration).permit(:originalRegistrationNumber)
  end

end
