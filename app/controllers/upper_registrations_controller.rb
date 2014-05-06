class UpperRegistrationsController < ApplicationController

  # GET upper-registrations/business-address
  def business_address
    update_model("business_address")
  end

  # POST upper-registrations/business-address
  def business_address_update

    update_model("business_address")

    if @registration.valid?
      redirect_to :upper_contact_detail
    else
      redirect_to :upper_business_address
    end
  end

  # GET upper-registrations/contact-detail
  def contact_detail
    update_model("contact_detail")
  end

  # POST upper-registrations/contact-detail
  def contact_detail_update

    update_model("contact_detail")

    if @registration.valid?
      redirect_to :upper_business_type
    else
      redirect_to :upper_contact_detail
    end
  end

  # GET upper-registrations/business-type
  def business_type
    update_model("business_type")
  end

  # POST upper-registrations/business-type
  def business_type_update

    update_model("business_type")

    if @registration.valid?
      redirect_to :upper_business_detail
    else
      redirect_to :upper_business_type
    end
  end

  # GET upper-registrations/business-detail
  def business_detail
    update_model("business_detail")
  end

  # POST upper-registrations/business-detail
  def business_detail_update

    update_model("business_detail")

    if @registration.valid?
      redirect_to :upper_relevant_conviction
    else
      redirect_to :upper_business_detail
    end
  end

  # GET upper-registrations/relevant-conviction
  def relevant_conviction
    update_model("relevant_conviction")
  end

  # POST upper-registrations/relevant-conviction
  def relevant_conviction_update

    update_model("relevant_conviction")

    if @registration.valid?
      redirect_to :upper_payment
    else
      redirect_to :upper_relevant_conviction
    end
  end

  # GET upper-registrations/payment
  def payment
    update_model("payment")
  end

  # POST upper-registrations/payment
  def payment_update

    update_model("payment")

    if @registration.valid?
      redirect_to :upper_summary
    else
      redirect_to :upper_payment
    end
  end

  # GET upper-registrations/summary
  def summary
    update_model("summary")
  end

  # POST upper-registrations/summary
  def summary_update

    update_model("summary")

    if @registration.valid?
      redirect_to :upper_summary
    else
      redirect_to :upper_summary
    end
  end

  private

  def update_model(current_step)
    @registration = UpperRegistration.new
    session[:upper_reg_params] ||= {}
    session[:upper_reg_params].deep_merge!(upper_reg_params) if params[:upper_registration]

    @registration = UpperRegistration.new(session[:upper_reg_params])
    @registration.current_step = current_step
  end

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def upper_reg_params
    params.require(:upper_registration).permit(
      :business_name,
      :full_name,
      :job_title,
      :telephone_number,
      :email_address,
      :business_type,
      :company_house_number,
      :alt_full_name,
      :alt_job_title,
      :alt_telephone_number,
      :alt_email_address,
      :relevant_conviction,
      :copy_cards,
      :payment_method,
      :carrier_dealer,
      :broker_dealer,
      :carrier_broker_dealer)
  end

end
