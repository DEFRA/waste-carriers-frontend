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
    @registration.originalRegistrationNumber = registration_params[:originalRegistrationNumber].strip.upcase

    # Validate which type of registration applied with, legacy IR system, Lower, or Upper current system
    # Check current format
    if existing_registration?
      logger.debug "Current registration matched, Redirect to user sign in"
      redirect_to(:new_user_session) and return
    elsif existing_ir_registration?
      logger.debug "Legacy registration matched, Redirect to smart answers"
      redirect_to(:business_type) and return
    end

    # If we are here, and there are no existing errors there must be validation
    # errors so add a validation error and re-render view with a 400 status
    if @registration.errors.empty?
      @registration.errors.add(:originalRegistrationNumber, I18n.t('errors.messages.invalid_registration_number'))
    end
    render 'show', status: :bad_request

  end

  private

  def existing_registration?
    return false unless valid_registration_format?(@registration.originalRegistrationNumber)

    registration = Registration.find_by_registration_no(@registration.originalRegistrationNumber)

    unless registration.present?
      @registration.errors.add(:originalRegistrationNumber, I18n.t('errors.messages.registration_number_not_found'))
      return false
    end

    true
  end

  def existing_ir_registration?
    return false unless valid_ir_format?(@registration.originalRegistrationNumber)

    ir_registration = Registration.find_by_ir_number(@registration.originalRegistrationNumber)

    unless ir_registration.present?
      @registration.errors.add(:originalRegistrationNumber, I18n.t('errors.messages.registration_number_not_found'))
      return false
    end

    # IR data found, merge with registration in redis
    # Access Code and reg_uuid should not get overriden with IR data
    @registration.add(ir_registration.attributes.except(:reg_uuid, :accessCode))
    @registration.save
  
    true
  end

  def registration_params
    params.require(:registration).permit(:originalRegistrationNumber)
  end

end
