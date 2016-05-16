class TemplatesController < ApplicationController

  # GET /templates/form
  def formExample
    new_step_action 'formExample'
  end

  # POST /templates/form
  def updateFormExample
    setup_registration 'formExample'

    if @registration.valid?
      logger.debug 'Registration is valid so far, go to next page'
      redirect_to :root
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.debug 'Registration is not valid, and data is not yet saved'
      render "formExample", :status => '400'
    end
  end

  def formTemplate
    new_step_action 'formTemplate'
  end

  # POST /templates/form-template
  def updateFormTemplate
    setup_registration 'formTemplate'

    if @registration.valid?
      logger.debug 'Registration is valid so far, go to next page'
      redirect_to :root
    elsif @registration.new_record?
      # there is an error (but data not yet saved)
      logger.debug 'Registration is not valid, and data is not yet saved'
      render "formTemplate", :status => '400'
    end
  end

  def new_step_action current_step

    @registration = Registration.create
    session[:registration_id]= @registration.id
    logger.debug "creating new registration #{@registration.id}"
    m = Metadata.create
    @registration.metaData.add m

    # TODO by setting the step here this should work better with forward and back buttons and urls
    # but this might have changed the behaviour
    @registration.current_step = current_step
    @registration.save
  end

  def setup_registration current_step, no_update=false
    @registration = Registration[ session[:registration_id]]
    @registration.add( params[:registration] ) unless no_update
    @registration.save
    @registration.current_step = current_step
  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def registration_params
    params.require(:registration).permit(
      :company_house_number,
      :alt_first_name,
      :alt_last_name,
      :alt_job_title,
      :alt_telephone_number,
      :alt_email_address,
      :primary_first_name,
      :primary_last_name,
      :primary_job_title,
      :primary_telephone_number,
      :primary_email_address,
      :businessType,
      :registrationType,
      :otherBusinesses,
      :isMainService,
      :constructionWaste,
      :onlyAMF,
      :companyName,
      :routeName,
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
      :registration_phase,
      :company_no,
      :registration_fee,
      :copy_card_fee,
      :copy_cards,
      :total_fee,
      :address_match_list,
      :sign_up_mode)
  end

end
