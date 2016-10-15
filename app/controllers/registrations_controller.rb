class RegistrationsController < ApplicationController

  include WorldpayHelper
  include RegistrationsHelper

  module Status
    REVOKED = -2
    EXPIRED = -1
    PENDING = 0
    ACTIVE = 1
  end

  # We require authentication (and authorisation) largely only for editing registrations,
  # and for viewing the finished/completed registration.
  module EditResult
    START = -999
    NO_CHANGES = 1
    UPDATE_EXISTING_REGISTRATION_NO_CHARGE = 2
    UPDATE_EXISTING_REGISTRATION_WITH_CHARGE = 3
    CREATE_NEW_REGISTRATION = 4
    CHANGE_NOT_ALLOWED = 5
  end

  module EditMode
    EDIT = 1
    RENEWAL = 2
  end

  before_action :authenticate_admin_request!

  before_action :authenticate_external_user!, only: [:update, :destroy, :finish, :view]

  # GET /registrations
  # GET /registrations.json
  def index
    authenticate_agency_user!
    searchWithin = params[:searchWithin]
    searchString = params[:q]
    if validate_search_parameters?(searchString,searchWithin)
      @registrations = []
      unless searchString.blank?
        @registrations = Registration.find_all_by(searchString, searchWithin)
      end
    else
      @registrations = []
      flash.now[:notice] = I18n.t('errors.messages.search_criteria')
    end

    # session[:registration_step] = session[:registration_params] = nil

    # REVIEWME: Ideally this should not be needed but in order to cover the 'Back and refresh issue'
    # The variables will be cleared for subequent requests
    # This will not fix a user clicking and Edit then using browser back, and then clicking a link
    # that was present, e.g click an edit, go back then click New registration.
    #
    # clear_edit_session
    # clear_registration_session
    # clear_order_session
    # logger.debug "Cleared registration session variables"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrations }
    end
  end


  # GET /your-registration/:reg_uuid/contact-details
  def contact_details
    new_step_action 'contactdetails'
    return unless @registration
  end

  # GET /your-registration/:reg_uuid/contact-details/edit
  def edit_contact_details
    new_step_action 'contactdetails'
    return unless @registration

    session[:edit_link_contact_details] = @registration.reg_uuid

    render :contact_details
  end

  # POST /your-registration/contact-details
  def update_contact_details
    setup_registration 'contactdetails'
    return unless @registration

    if @registration.valid?
      if session[:edit_link_contact_details] == @registration.reg_uuid
        session.delete(:edit_link_contact_details)
        redirect_to declaration_path(@registration.reg_uuid)
        return
      end
      redirect_to :postal_address
    else
      # there is an error (but data not yet saved)
      logger.debug 'Registration is not valid, and data is not yet saved'
      render :contact_details, status: :bad_request
    end
  end

  def relevant_convictions
    new_step_action 'convictions'
    return unless @registration
  end

  def update_relevant_convictions
    setup_registration 'convictions'
    return unless @registration

    if @registration.valid?
      set_google_analytics_convictions_indicator(session, @registration)
      #      (redirect_to declaration_path(reg_uuid: @registration.reg_uuid) and return) if session[:edit_mode]
      if @registration.declaredConvictions == 'yes'
        redirect_to relevant_people_path(@registration.reg_uuid)
      else
        redirect_to declaration_path(@registration.reg_uuid)
      end
    else
      # there is an error (but data not yet saved)
      logger.debug 'Registration is not valid, and data is not yet saved'
      render :relevant_convictions, status: :bad_request
    end
  end

  # GET /your-registration/:reg_uuid/declaration
  def declaration
    @registration = Registration.find(reg_uuid: params[:reg_uuid]).first
    @registration_order = RegistrationOrder.new(@registration)

    # logger.debug "any addresses? #{@registration.addresses.any?}"
  end

  # POST /your-registration/:reg_uuid/declaration
  def update_declaration
    setup_registration 'declaration'
    return unless @registration

    if @registration.valid?
      if @registration.order_types.include? :edit
        if @registration.order_types.include? :change_reg_type
          order_edit(@registration.uuid)
        elsif @registration.order_types.include? :change_caused_new
          # If a new registration is needed at this point it should be created
          # as the payment will then be processed against that registration and
          # not the original one, which will be marked as deleted
          new_reg = Registration.create_new_when_edit_requires_new_reg(@registration)

          # Need to re-get registration from DB as we are leaving the orig alone
          original_reg = Registration.find_by_id(@registration.uuid)
          # Mark original registration as deleted and save to db
          original_reg.metaData.first.update(status: 'INACTIVE')

          if original_reg.save!
            original_reg.save
          end

          # Use copy of registration in memory and save to database
          new_reg.current_step = 'declaration'
          if new_reg.valid?
            if new_reg.commit
              new_reg.save
              @registration = new_reg

              # TODO: Commenting this, removing all things session related
              # Remove before finishing this work.
              # session[:registration_id] = new_reg.id
              # session[:registration_uuid] = @registration.uuid

            else
              render 'declaration', status: :bad_request
            end
          else
            render 'declaration', status: :bad_request
          end

          # Save copied registration to redis and update any session variables
          @registration.save
          redirect_to upper_payment_path(reg_uuid: @registration.reg_uuid, order_type: Order.editrenew_caused_new_identifier) && return

          ## ---- End of "if @registration.order_types.include? :change_caused_new" ---- ##

        elsif @registration.order_types.include? :renew
          edit_mode = session[:edit_mode]
          edit_result = session[:edit_result]
          # we don't need edit variables polluting the session any more
          clear_edit_session
          redirect_to complete_edit_renew_path(@registration.uuid)
          return
        else # upper tier edit with no charge
          complete_edit_that_has_no_charge and return
        end

        return

        ## ---- End of "if @registration.order_types.include? :edit" ---- ##

      elsif @registration.order_types.include? :renew
        # Detect standard or IR renewal
        if @registration.originalRegistrationNumber && isIRRegistrationType(@registration.originalRegistrationNumber) && @registration.newOrRenew
          redirect_to :account_mode and return
        else
          @registration.renewalRequested = true

          @registration.save
          order_renew(@registration.uuid) and return
        end

      elsif @registration.lower? && @registration.persisted?
        complete_edit_that_has_no_charge and return
      else # new registration
        redirect_to :account_mode and return
      end

      return

    else
      # there is an error (but data not yet saved)
      render :declaration
    end
  end

  # Helper for above function that should be called when the user has completed
  # an edit to their registration that does not incur any charge.
  def complete_edit_that_has_no_charge
    @registration.save!
    clear_edit_session
    if current_user
      redirect_to user_registrations_path(current_user)
    elsif current_agency_user
      redirect_to registrations_path
    else
      renderAccessDenied
    end
  end

  # GET /your-registration/:reg_uuid/account-mode
  def account_mode
    new_step_action 'account-mode'
    return unless @registration

    user_signed_in = false
    agency_user_signed_in = false

    if user_signed_in?
      @registration.accountEmail = current_user.email
      @user = User.find_by_email(@registration.accountEmail)
      user_signed_in = true
    elsif agency_user_signed_in?
      if @registration.accountEmail.blank?
        # Only update the account email if not already set.  This allows users
        # who drop-off at payment, but use NCCC to make a payment, stay as
        # digital users.
        @registration.accountEmail = current_agency_user.email
      end
      @user = User.find_by_email(current_agency_user.email)
      agency_user_signed_in = true
    else
      @registration.accountEmail = @registration.contactEmail
    end

    # Get signup mode
    account_mode_val = @registration.initialize_sign_up_mode(@registration.accountEmail, (user_signed_in || agency_user_signed_in))

    @registration.sign_up_mode = account_mode_val
    logger.debug "Account mode is #{account_mode_val} and sign_up_mode is #{@registration.sign_up_mode}"
    @registration.save

    case account_mode_val
      when 'sign_in'
        redirect_to action: :signin
      when 'sign_up'
        redirect_to action: :signup
      else
        if @registration.valid?
          case @registration.tier
            when 'LOWER'
              if complete_new_registration(true)
                logger.debug "Registration created, about to check user type"
                if user_signed_in
                  redirect_to finish_path(reg_uuid: @registration.reg_uuid)
                else
                  redirect_to finish_assisted_path(reg_uuid: @registration.reg_uuid)
                end
              else
                @registration.errors.add(:exception, "Unable to commit registration")
                render "declaration", status: :bad_request
              end
            when 'UPPER'
              complete_new_registration
              #
              # Important!
              # Now storing an additional variable in the session for the type of order
              # you are about to make.
              # This session variable needs to be set every time the order/new action
              # is requested.
              #
              if @registration.originalRegistrationNumber &&
                  isIRRegistrationType(@registration.originalRegistrationNumber) &&
                  @registration.newOrRenew
                order_renew(@registration.uuid) and return
              else
                order(@registration.uuid) and return
              end
          end
        else
          render "declaration", status: :bad_request
        end
    end

  end

  # GET /your-registration/:reg_uuid/signin
  def signin
    new_step_action 'signin'
    return unless @registration
    session[:at_mid_registration_signin_step] = @registration.reg_uuid
    @registration.sign_up_mode = 'sign_in'
  end

  # POST /your-registration/:reg_uuid/signin
  def update_signin
    setup_registration 'signin'
    return unless @registration

    unless user_signed_in?
      @user = User.find_by_email(@registration.accountEmail)
      if @registration.valid?
        sign_in @user
      else
        logger.error "GGG ERROR - password not valid for user with e-mail"
        render "signin", status: :bad_request
        return
      end
    end

    unless @registration.valid?
      # there is an error (but data not yet saved)
      logger.debug 'Registration is not valid, and data is not yet saved'
      render "signin", status: :bad_request
      return
    end

    complete_new_registration(@registration.tier == 'LOWER')

    session.delete(:at_mid_registration_signin_step)
    @registration.sign_up_mode = ''
    @registration.save

    case @registration.tier
      when 'LOWER'
        redirect_to finish_path(reg_uuid: @registration.reg_uuid)
      when 'UPPER'
        #
        # Important!
        # Now storing an additional variable in the session for the type of order
        # you are about to make.
        # This session variable needs to be set every time the order/new action
        # is requested.
        #

        # Determine what type of registration order to create
        # If an originalRegistrationNumber is presenet in the registration, then the registration is an IR Renewal
        if @registration.originalRegistrationNumber and isIRRegistrationType(@registration.originalRegistrationNumber)
          if session[:edit_result]
            case session[:edit_result].to_i
              when  EditResult::NO_CHANGES, EditResult::UPDATE_EXISTING_REGISTRATION_NO_CHARGE, EditResult::UPDATE_EXISTING_REGISTRATION_WITH_CHARGE
                # no charge or ir renewal with charge
                order_renew @registration.uuid
              when  EditResult::CREATE_NEW_REGISTRATION
                # ir renewal converted to new because of changes
                order @registration.uuid
              else
                # standard renewal
                order_renew @registration.uuid
            end
          else
            order_renew @registration.uuid
          end
        else
          order @registration.uuid
        end
    end
  end

  # GET /your-registration/:reg_uuid/signup
  def signup
    new_step_action 'signup'
    return unless @registration
    @registration.sign_up_mode = 'sign_up'
  end

  # POST /your-registration/:reg_uuid/signup
  def update_signup
    setup_registration 'signup'
    return unless @registration

    # Quick fix to prevent Rails default validation failure firing when account already exists
    @registration.accountEmail = format_email(@registration.accountEmail.downcase)
    @registration.accountEmail_confirmation = format_email(@registration.accountEmail_confirmation.downcase)

    if @registration.valid?
      logger.debug 'The registration is valid...'
      logger.debug 'Check to commit registration, unless: ' + @registration.persisted?.to_s
      unless @registration.persisted?
        # Note: we have to store the new user first, and only if that succeeds, we want to commit the registration
        logger.debug 'Check to commit user'
        unless current_user
          unless commit_new_user
            render "signup", status: :bad_request
            return
          end
        end

        if commit_new_registration?
          logger.debug 'The new registration has been committed successfully'
        else #registration was not committed
          logger.error 'Registration was valid but data is not yet saved due to an error in the services'
          @registration.errors.add(:exception, @registration.exception.to_s)
          render "signup", status: :bad_request
          return
        end
      end

    else # the registration is not valid
      # there is an error (but data not yet saved)
      logger.debug 'Registration is not valid, and data is not yet saved'
      render "signup", status: :bad_request
      return
    end

    logger.debug 'Determining next_step for redirection'

    next_step = case @registration.tier
                  when 'LOWER'
                    pending_url
                  when 'UPPER'

                    # Important!
                    # Now storing an additional variable in the session for the type of order
                    # you are about to make.
                    # This session variable needs to be set every time the order/new action
                    # is requested.

                    # Determine what type of registration order to create
                    # If an originalRegistrationNumber is present in the registration, then the registration is an IR Renewal
                    if @registration.originalRegistrationNumber and isIRRegistrationType(@registration.originalRegistrationNumber)
                      order_type = session[:renderType] = Order.renew_registration_identifier

                      # TODO: LB: Figure out how to get the editrenew_caused_new_identifier identified here
                      # if session[:edit_result]
                        # if session[:edit_result].to_i.eql? EditResult::CREATE_NEW_REGISTRATION
                        #  session[:renderType] = Order.editrenew_caused_new_identifier
                        # end
                      # end

                    else
                      order_type = Order.new_registration_identifier
                    end

                    upper_payment_path(@registration.reg_uuid, order_type: order_type)
                end

    # Reset Signed up user to signed in status
    @registration.sign_up_mode = 'sign_in'
    @registration.save!

    redirect_to next_step
  end

  # GET /registrations/:reg_uuid/finish
  def finish
    setup_registration 'finish'
    # Force regresh latest version from Java services / Mongo
    @registration = Registration.find_by_id(@registration.uuid)
    authorize! :read, @registration

    @confirmationType = getConfirmationType
    unless @confirmationType
      flash[:notice] = 'Invalid confirmation type. Check routing to this page'
      renderNotFound and return
    end
  end

  # POST /registrations/finish
  def update_finish
    if user_signed_in?
      redirect_to user_registrations_path(current_user)
    else
      redirect_to Rails.configuration.waste_exemplar_end_url
    end
  end

  # GET /registrations/finish-assisted
  def finish_assisted
    new_step_action 'finish_assisted'
    # Force regresh latest version from Java services / Mongo
    @registration = Registration.find_by_id(@registration.uuid)
    authorize! :read, @registration
  end

  # POST /registrations/finish-assisted
  def update_finish_assisted
    if agency_user_signed_in?
      redirect_to registrations_path
    else
      redirect_to controller: 'errors', action: 'server_error_500'
    end
  end

  # GET /registrations/cannot-edit
  def cannot_edit
  end

  def commit_new_registration?
    unless @registration.tier == 'LOWER'
      # ------------- Begin Note -----------------------------------------------
      # NOTE: the date determined below is currently irrelevant, as the Expiry
      # Date is chosen by the Java services.  However, we do need the value to
      # be **valid** to prevent validation errors in the services, and the logic
      # below may be useful in the future if we remove the services.

      # Detect standard or IR renewal
      if @registration.originalRegistrationNumber && isIRRegistrationType(@registration.originalRegistrationNumber) && @registration.newOrRenew
        # This is an IR renewal, so set the expiry date to 3 years from the
        # expiry of the existing IR registration.
        @registration.expires_on = convert_date(@registration.originalDateExpiry.to_i) + Rails.configuration.registration_expires_after
      else
        # This is a new registration; set the expiry date to 3 years from today.
        @registration.expires_on = (Date.current + Rails.configuration.registration_expires_after)
      end
      # Ensure value is always a Unix-like time, not a date, as Ohm/Redis handles
      # this better.
      @registration.expires_on = @registration.expires_on.to_time
      # ------------- End Note -----------------------------------------------
    end

    # Note: we are assigning a unique identifier to the registration in order to
    # make the POST request idempotent

    # TODO: Moved to model, no longer needed
    # @registration.reg_uuid = SecureRandom.uuid

    @registration.save
    if @registration.commit
      # session[:registration_uuid] = @registration.uuid
      # session[:registration_id] = @registration.id

      logger.debug "Registration commited"
      true
    else
      false
    end
  end

  def commit_new_user
    @user = User.new
    @user.email = @registration.accountEmail
    @user.password = @registration.password
    @user.current_tier = @registration.tier
    logger.debug "About to save the new user."
    if @user.save
      logger.debug 'User has been saved.'
      # In the case of new UT registrations we eventually redirect directly to the confirmed page without them
      # first having to have clicked the link in the confirmaton email. The Confirmed action relies on pulling
      # out the user from the session as when you do click the link the ConfirmationsController::after_confirmation_path_for
      # action stores the confirmed user there.
      # session[:userEmail] = @user.email
      return true
    else
      logger.debug 'Could not save user. Errors: ' + @user.errors.full_messages.to_s
      # Full messages returns an array, so join to avoid printing [ ] on screen
      @registration.errors.add(:accountEmail, @user.errors.full_messages.join(' '))
      return false
    end
  end

  def complete_new_registration(activate_registration = false)
    unless @registration.persisted?
      unless commit_new_registration?
        return false
      else
        logger.debug "Committed registration, about to activate if appropriate"
        @registration.activate! if activate_registration
        @registration.save
        if @registration.digital_route? && @registration.is_complete?
          RegistrationMailer.welcome_email(@user, @registration).deliver_now
        end
      end
    end
    true  # Either saved successfully, or was already in the database.
  end

  def validate_search_parameters?(searchString, searchWithin)
    searchString_valid = searchString == nil || !searchString.empty? && searchString.match(Registration::VALID_CHARACTERS)
    searchWithin_valid = searchWithin == nil || searchWithin.empty? || (['any','companyName','contactName','postcode'].include? searchWithin)
    searchString_valid && searchWithin_valid
  end

  def validate_public_search_parameters?(searchString, searchWithin, searchDistance, searchPostcode)
    searchString_valid = searchString == nil || !searchString.empty? && (!searchString.match(Registration::VALID_CHARACTERS).nil?)
    searchWithin_valid = searchWithin == nil || !searchWithin.empty? && (['any','companyName','contactName','postcode'].include? searchWithin)
    searchDistance_valid = searchDistance == nil || !searchDistance.empty? && (Registration::DISTANCES.include? searchDistance)
    searchPostcode_valid = searchPostcode == nil || searchPostcode.empty? || searchPostcode.match(Registration::POSTCODE_CHARACTERS)

    searchCrossField_valid = true
    # Add cross field check, to ensure that correct params supplied if needed
    unless searchString.nil?
      unless searchString.empty?
        if searchDistance.nil? || searchPostcode.nil?
          searchCrossField_valid = false
        end
      end
    end

    logger.debug 'Validate Public Search Params Q:' + searchString_valid.to_s + ' SW:' + searchWithin_valid.to_s + ' D:' + searchDistance_valid.to_s + ' P:' + searchPostcode_valid.to_s + ' CF: ' + searchCrossField_valid.to_s
    searchString_valid && searchWithin_valid && searchDistance_valid && searchPostcode_valid && searchCrossField_valid
  end

  def userRegistrations
    authenticate_external_user!

    # Search for users registrations
    @registrations = Registration.find_by_email(current_user.email,
                                                %w(ACTIVE PENDING REVOKED EXPIRED)).sort_by { |r| r.date_registered }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrations }
    end
  end

  # GET /registrations/1
  # GET /registrations/1.json
  def show
    renderNotFound
  end


  def view
    reg_uuid = params[:id] || session[:registration_uuid]

    renderNotFound and return unless reg_uuid
    @registration = Registration.find_by_id( reg_uuid )
    redirect_to registrations_path and return unless @registration

    authorize! :read, @registration
    if params[:finish]
      if agency_user_signed_in?
        logger.debug 'Keep agency user signed in before redirecting back to search page'
        redirect_to registrations_path
      else
        logger.debug 'Sign user out before redirecting back to GDS site'
        sign_out # Performs a signout action on the current user
        redirect_to Rails.configuration.waste_exemplar_end_url
      end
    elsif params[:back]
      logger.debug 'Default, redirecting back to Finish page'
      redirect_to finish_path(reg_uuid: @registration.reg_uuid)
    else
      # Turn off default gov uk template so certificate can be printed exactly as is
      respond_to do |format|
        format.html do
          render 'certificate', layout: 'non_govuk_template'
        end
        format.pdf do
          @pdf = true
          render pdf: "certificate",
            template: 'registrations/certificate.html.erb',
            layout: 'pdf.html.erb',
            background: true
        end
      end
      logger.debug 'Save View state in the view page (go to Finish)'
      flash[:alert] = 'Finish'
    end
  end

  # GET /your-registration/:reg_uuid/confirmed
  def confirmed
    setup_registration 'confirmed'

    @user = User.find_by_email(@registration.accountEmail)

    renderNotFound and return unless @user
    renderNotFound and return unless @registration

    @confirmationType = getConfirmationType

    unless @confirmationType
      flash[:notice] = 'Invalid confirmation type. Check routing to this page.'
      renderNotFound and return
    end
  end

  def complete_confirmed
    #
    # Finished here, ok to clear session variables
    #
    clear_registration_session
    reset_session
    redirect_to Rails.configuration.waste_exemplar_end_url
  end

  def version
    @railsVersion = Rails.configuration.application_version

    # Request version from REST api
    @apiVersionObj = Version.find(:one, :from => "/version.json" )
    unless @apiVersionObj.nil?
      logger.debug 'Version info, version number:' + @apiVersionObj.versionDetails + ' lastBuilt: ' + @apiVersionObj.lastBuilt
      @apiVersion = @apiVersionObj.versionDetails
    end

    render :layout => false
  end

  # GET /registrations/new
  # GET /registrations/new.json
  def new
    renderNotFound
  end


  # GET /registrations/1/edit
  def edit
    @registration = Registration.find_by_id(params[:id])
    renderNotFound and return unless @registration

    logger.debug "registration edit for: #{@registration.reg_uuid}"

    logger.debug "any addresses? #{@registration.addresses.any?}"

    authorize! :update, @registration

    # Helps display the correct wording on the confirmation page
    flash[:start_editing] = true

    redirect_to declaration_path(reg_uuid: @registration.reg_uuid)
  end

  # GET, PATCH /registrations/1/edit_account_email
  def edit_account_email
    logger.debug "edit account email for: #{params[:uuid]}"
    @registration = Registration.find_by_id(params[:uuid])

    renderNotFound and return unless @registration

    authorize! :update, @registration

    if request.patch?
      if (params[:registration][:accountEmail] != @registration.accountEmail)
        @user = User.find_by_email(@registration.accountEmail)
        @user.skip_reconfirmation!
        @user.email = params[:registration][:accountEmail]
        @user.save!(:validate => false)
        @user.send_reset_password_instructions
        @registration.accountEmail = params[:registration][:accountEmail]
        @registration.save!
        flash.now[:notice] = I18n.t('agency_users.edit_account_email.email_updated', new_email: @registration.accountEmail)
        flash.now[:instructions] = I18n.t('agency_users.edit_account_email.pwreset_reminder')
      else
        @registration.errors.add(:accountEmail, I18n.t('agency_users.edit_account_email.email_not_updated'))
      end
    end

  end

  def paymentstatus
    @registration = Registration.find_by_id(params[:id])
    if @registration.nil?
      renderNotFound
      return
    end
    authorize! :read, @registration
    authorize! :read, Payment
  end

  def copyAddressToSession
    logger.debug 'Copying address details into the registration...'

    @registration = Registration[session[:registration_id]]
    @address = @registration.registered_address
    @address.populate_from_address_search_result(@selected_address)
  end

  def pending
    redis_registration = Registration.find(reg_uuid: params[:reg_uuid]).first
    @registration = Registration.find_by_id(redis_registration.uuid)

    # May not be necessary but seeing as we get a fuller object from services
    # at this point thought as a 'just in case' we should update the one in redis
    @registration.save

    # user = @registration.user
    # user.current_registration = @registration
    # user.send_confirmation_instructions unless user.confirmed?
  end

  # DELETE /registrations/1
  # DELETE /registrations/1.json
  def destroy
    @registration = Registration.find_by_id(params[:id])
    deletedCompany = @registration.companyName
    authorize! :update, @registration
    @registration.metaData.first.update(:status => 'INACTIVE')
    @registration.save!

    if current_user
      respond_to do |format|
        format.html { redirect_to user_registrations_path(current_user.id, :note => 'De-Registered ' + deletedCompany) }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to registrations_path(:note => 'De-Registered ' + deletedCompany) }
        format.json { head :no_content }
      end
    end
  end

  def confirmDelete
    @registration = Registration.find_by_id(params[:id])
    authorize! :update, @registration
  end

  #####################################################################################
  # Revoke / Unvoke
  #####################################################################################

  def revoke
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration
    @isRevoke = true
  end

  def unRevoke
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration
    @isRevoke = false
    # Reuses revoke view for un-revoke functionality
    render :revoke
  end

  def updateRevoke
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration

    # Validate if is in a correct state to revoke/unrevoke?
    if params[:revoke]                      # Checks the type of request, ie which button was clicked
      if @registration.is_revocable?        # Checks if revocable, i.e. is registration in a state that can be made revoked
        unless params[:registration][:metaData][:revokedReason].empty?     # Checks the reason was provided
          if agency_user_signed_in?                                     # Checks only agency users can revoke
            # Get reason from params
            revokedReason = params[:registration][:metaData][:revokedReason]

            # Update registration with revoked comment and status
            @registration.metaData.first.update(revokedReason: revokedReason)
            @registration.metaData.first.update(status: 'REVOKED')

            # Save changes to registration
            @registration.save
            @registration.save!
            logger.debug "uuid: #{@registration.uuid}"

            # We don't send a revoke email, because NCCC handle this process manually.

            # Redirect to registrations page
            redirect_to registrations_path(note: I18n.t('registrations.form.reg_revoked')) and return
          else
            renderAccessDenied and return
          end
        else
          # Reason not provided
          @registration.errors.add(:revokedReason, I18n.t('errors.messages.blank'))
        end
      else
        # Error: Not ready for revoke  TODO: Replace this with better message
        @registration.errors.add(:revokedReason, I18n.t('errors.messages.blank'))
      end
    else
      # check if unrevocable
      if @registration.is_unrevocable?
        unless params[:registration][:metaData][:unrevokedReason].empty?
          if agency_user_signed_in?
            # Get reason from params
            unrevokedReason = params[:registration][:metaData][:unrevokedReason]

            # Mark registration as unrevoked, i.e. reactivated
            @registration.metaData.first.update(revokedReason: unrevokedReason)
            @registration.metaData.first.update(status: 'ACTIVE')

            # Save changes to registration
            @registration.save
            @registration.save!
            logger.debug "uuid: #{@registration.uuid}"

            # QUESTION: Do we Send email to say reactivated? Resend registration perhaps?

            # Redirect to registrations page
            redirect_to registrations_path(:note => 'Registration reactivated' ) and return
          end
        else
          # Reason not provided
          @registration.errors.add(:unrevokedReason, I18n.t('errors.messages.blank'))
        end
      else
        # Error: Not ready for unrevoke  TODO: Replace this with better message
        @registration.errors.add(:unrevokedReason, I18n.t('errors.messages.blank'))
      end
    end

    # Error must have occured return to original view with errors
    if params[:revoke]
      # from revoke
      @isRevoke = true
      render :revoke, status: :bad_request
    else
      # from unrevoke
      @isRevoke = false
      render :revoke, status: :bad_request
    end
  end
  #####################################################################################
  # Approve / Refuse
  #####################################################################################

  def approve
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration
    @isApprove = true
  end

  def refuse
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration
    @isApprove = false
    # Reuses approve view for refuse functionality
    render :approve
  end

  def updateApprove
    @registration = Registration.find_by_id(params[:id])
    authorize! :approve, @registration

    # Validate if is in a correct state to approve/refuse?
    if params[:approve]
      # Approve
      logger.debug '>>>>>> Approve Request Found'
      unless params[:registration][:metaData][:approveReason].empty?     # Checks the reason was provided
        if agency_user_signed_in?                                     # Checks only agency users can approve
          # Get reason from params
          approveReasonParam = params[:registration][:metaData][:approveReason]

          # Update registration with revoked comment and status
          @registration.metaData.first.update(revokedReason: approveReasonParam)
          #@registration.metaData.first.update(status: 'ACTIVE')                    # Should not need to do this directly if conviction check has been cleared

          # Perform action needed to clear conviction check
          if @registration.conviction_sign_offs
            @registration.conviction_sign_offs.each do |sign_off|
              # Update conviction sign off data
              sign_off.update(confirmed: 'yes')
              sign_off.update(confirmedAt: Time.now.utc.xmlschema)
              sign_off.update(confirmedBy: current_agency_user.email)
            end
          end

          # Save changes to registration
          if @registration.save!
            @registration.save
            logger.debug "uuid: #{@registration.uuid}"

            unless @registration.assisted_digital?
              if @registration.paid_in_full?
                @user = User.find_by_email(@registration.accountEmail)
                RegistrationMailer.welcome_email(@user, @registration).deliver_now
              end
            end

            # Redirect to registrations page
            redirect_to registrations_path(:note => I18n.t('registrations.form.reg_approved') ) and return
          else
            # Failed to save registration in database
            @registration.errors.add(:exception, 'Failed to save approve in DB')
          end
        else
          renderAccessDenied and return
        end
      else
        @registration.errors.add(:approveReason, I18n.t('errors.messages.blank'))
      end
    else
      # Refuse
      if @registration.is_awaiting_conviction_confirmation?(current_agency_user)        # Checks if refusable, i.e. is registration in a state that can be made refused
        unless params[:registration][:metaData][:refusedReason].empty?                     # Checks the reason was provided
          # Get reason from params
          refusedReasonParam = params[:registration][:metaData][:refusedReason]

          # Update registration with refused comment and status
          @registration.metaData.first.update(revokedReason: refusedReasonParam)
          @registration.metaData.first.update(status: 'REFUSED')

          # Save changes to registration
          if @registration.save!
            @registration.save
            logger.debug "uuid: #{@registration.uuid}"

            # Redirect to registrations page
            redirect_to registrations_path(:note => I18n.t('registrations.form.reg_refused') ) and return
          else
            # Failed to save registration in database
            @registration.errors.add(:exception, @registration.exception.to_s)
          end
        else
          @registration.errors.add(:refusedReason, I18n.t('errors.messages.blank'))
        end
      else
        renderAccessDenied and return
      end
    end

    # Error must have occured return to original view with errors
    if params[:approve]
      # from approve
      @isApprove = true
      render :approve, status: :bad_request
    else
      # from refuse
      @isApprove = false
      render :approve, status: :bad_request
    end
  end

  #####################################################################################

  def publicSearch
    distance = params[:distance]
    searchString = params[:q]
    postcode = params[:postcode]
    if validate_public_search_parameters?(searchString,"any",distance, postcode)
      if searchString && !searchString.empty?


        param_args = {
            q: searchString,
            searchWithin: 'companyName',
            distance: distance,
            activeOnly: 'true',
            postcode: postcode,
            excludeRegId: 'true' }


        @registrations = Registration.find_by_params(param_args)
      else
        @registrations = []
      end
    else
      @registrations = []
      flash.now[:notice] = I18n.t('registrations.form.invalid_public_params')
    end
  end

  def notfound
    redirect_to registrations_path(:error => params[:message] )
  end

  def logger
    Rails.logger
  end

  def authenticate_admin_request!
    authenticate_agency_user! if is_admin_request?
  end

  def authenticate_external_user!
    authenticate_user! if (!is_admin_request? && !agency_user_signed_in?)
  end

  # Function to redirect newOrders to the order controller
  def order(registration_uuid)
    redirect_to upper_payment_path(reg_uuid: @registration.reg_uuid, order_type: Order.new_registration_identifier)
  end

  # Function to redirect registration edit orders to the order controller
  def order_edit(registration_uuid)
    redirect_to upper_payment_path(reg_uuid: @registration.reg_uuid, order_type: Order.edit_registration_identifier)
  end

  # Function to redirect registration renew orders to the order controller
  def order_renew(registration_uuid)
    redirect_to upper_payment_path(reg_uuid: @registration.reg_uuid, order_type: Order.renew_registration_identifier)
  end

  # Function to redirect additional copy card orders to the order controller
  def order_copy_cards
    set_registration_from_uuid_or_reg_uuid
    redirect_to upper_payment_path(reg_uuid: @registration.reg_uuid, order_type: Order.extra_copycards_identifier)
  end

  # Renders the additional copy card order complete view
  def copy_card_complete
    set_registration_from_uuid_or_reg_uuid
    @confirmationType = getConfirmationType
    authorize! :read, @registration
  end

  # Renders the edit renew order complete view
  def edit_renew_complete
    set_registration_from_uuid_or_reg_uuid

    # Force regresh latest version from Java services / Mongo
    @registration = Registration.find_by_id(@registration.uuid)

    @confirmationType = getConfirmationType
    
    # Determine routing for Finish button
    @exitRoute = if @registration.originalRegistrationNumber && isIRRegistrationType(@registration.originalRegistrationNumber) && @registration.newOrRenew
      confirmed_path(reg_uuid: @registration.reg_uuid)
    elsif current_agency_user
      finish_assisted_path(reg_uuid: @registration.reg_uuid)
    else
      finish_path(reg_uuid: @registration.reg_uuid)
    end

    clear_edit_session
  end

  def offline_payment
    new_step_action 'offline_payment'

    if @registration
      @order = @registration.getOrder(params[:orderCode])
    else
      logger.warn 'Registration not found by reg_uuid'
      renderNotFound and return
    end
  end

  def update_offline_payment
    setup_registration 'offline_payment'

    @order = @registration.getOrder(params[:order_code])
    @order_type = params[:order_type]

    # Validate that actions only occur here if a order type is set
    (renderAccessDenied and return) unless @order || order_type

    if @registration.digital_route? && !(@order_type == Order.extra_copycards_identifier)
      logger.debug 'Send registered email (if not agency user)'
      @user = User.find_by_email(@registration.accountEmail)
      Registration.send_registered_email(@user, @registration)
    end

    next_step = if @order_type.eql?(Order.extra_copycards_identifier)
                  # redirect to copy card complete page
                  complete_copy_cards_path(@registration.uuid)
                elsif @order_type.eql?(Order.edit_registration_identifier)
                  # redirect to edit complete
                  complete_edit_renew_path(@registration.uuid)
                elsif @order_type.eql?(Order.renew_registration_identifier)
                  # redirect to renew complete
                  complete_edit_renew_path(@registration.uuid)
                elsif user_signed_in?
                  finish_path(reg_uuid: @registration.reg_uuid)
                elsif agency_user_signed_in?
                  finish_assisted_path(reg_uuid: @registration.reg_uuid)
                else
                  confirmed_path
                end

    redirect_to next_step

  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def registration_params
    params.require(:registration).permit(
      :businessType,
      :registrationType,
      :otherBusinesses,
      :isMainService,
      :constructionWaste,
      :onlyAMF,
      :companyName,
      :postcodeSearch,
      :firstName,
      :lastName,
      :position,
      :phoneNumber,
      :contactEmail,
      :accountEmail,
      :declaration,
      :password,
      :password_confirmation,
      :accountEmail_confirmation,
      :tier,
      :company_no,
      :registration_fee,
      :copy_card_fee,
      :copy_cards,
      :total_fee,
      :address_match_list,
    :sign_up_mode)
  end

end
