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
    if existing_registration? && can_renew_registration?
      renewals_url = "#{Rails.configuration.renewals_service_url}#{@registration.regIdentifier}"
      redirect_to(renewals_url) and return
    elsif existing_ir_registration? && can_renew_ir_registration?
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

    # Record found, so for the sake of accessing the data the subsequent checks
    # need we overwrite our global registration object with what came back from
    # the Java services.
    # We don't save it however, as we cannot describe what would happen should
    # the user cancel the renewal and attempt to start a new registration.
    @registration = registration

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

  def can_renew_registration?
    # We have to convert the date because its returned as milliseconds since the
    # epoch (1970-1-1).
    expiry_date = convert_date(@registration.expires_on.to_i)

    return false if expired?(expiry_date)

    return false unless in_renewal_window?(expiry_date)

    return false unless status_eligible?(@registration.metaData.first.status)

    true
  end

  def can_renew_ir_registration?
    # We have to convert the date because its returned as milliseconds since the
    # epoch (1970-1-1).
    expiry_date = convert_date(@registration.originalDateExpiry.to_i)

    return false if expired?(expiry_date)

    return false unless in_renewal_window?(expiry_date)

    return false if already_renewed?(@registration.originalRegistrationNumber)

    true
  end

  def expired?(expiry_date)
    # Registrations are expired on the date recorded for their expiry date e.g.
    # an expiry date of Mar 25 2018 means the registration was active up till
    # 24:00 on Mar 24 2018.
    return false if expiry_date.to_date > Date.today

    @registration.errors.add(
      :originalRegistrationNumber,
      I18n.t('errors.messages.registration_expired')
    )
    true
  end

  def in_renewal_window?(expiry_date)
    # If the registration expires in more than x months from now, its outside
    # the renewal window
    return true if expiry_date.to_date < Rails.configuration.registration_renewal_window.from_now

    renew_from = date_can_renew_from(expiry_date)

    @registration.errors.add(
      :originalRegistrationNumber,
      I18n.t(
        'errors.messages.registration_not_in_renewal_window',
        date: renew_from.strftime('%A ' + renew_from.mday.ordinalize + ' %B %Y')
      )
    )
    false
  end

  def status_eligible?(status)
    return true if status == 'ACTIVE'

    @registration.errors.add(
      :originalRegistrationNumber,
      I18n.t(
        'errors.messages.registration_not_active',
        helpline: Rails.configuration.registrations_service_phone.to_s
      )
    )

    false
  end

  def already_renewed?(reference_number)
    registration = Registration.find_by_original_registration_no(reference_number)

    return false unless registration.present? && registration.metaData.first.status != 'PENDING'

    @registration.errors.add(
      :originalRegistrationNumber,
      I18n.t(
        'errors.messages.registration_already_renewed',
        helpline: Rails.configuration.registrations_service_phone.to_s
      )
    )
    true
  end

  def registration_params
    params.require(:registration).permit(:originalRegistrationNumber)
  end

end
