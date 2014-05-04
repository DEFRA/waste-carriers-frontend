class UpperRegistrationsController < ApplicationController

  # GET upper-registrations/business-details
  def business_details
    @registration = UpperRegistration.new
    session[:upper_reg_params] ||= {}
    session[:upper_reg_params].deep_merge!(upper_reg_params) if params[:upper_registration]

    @registration = UpperRegistration.new(session[:upper_reg_params])
    @registration.current_step = "business_detail"
  end

  # POST upper-registrations/business-details
  def business_details_update
    session[:upper_reg_params] ||= {}
    session[:upper_reg_params].deep_merge!(upper_reg_params) if params[:upper_registration]

    @registration = UpperRegistration.new(session[:upper_reg_params])
    @registration.current_step = "business_detail"

    if @registration.valid?
      redirect_to :upper_contact_detail
    else
      redirect_to :upper_business_details
    end
  end

  # GET upper-registrations/contact-detail
  def contact_detail
    @registration = UpperRegistration.new
    session[:upper_reg_params] ||= {}
    session[:upper_reg_params].deep_merge!(upper_reg_params) if params[:upper_registration]

    @registration = UpperRegistration.new(session[:upper_reg_params])
    @registration.current_step = "contact_detail"
  end

  # POST upper-registrations/contact-detail
  def contact_detail_update
    @registration = UpperRegistration.new
    session[:upper_reg_params] ||= {}
    session[:upper_reg_params].deep_merge!(upper_reg_params) if params[:upper_registration]

    @registration = UpperRegistration.new(session[:upper_reg_params])
    @registration.current_step = "contact_detail"

    if @registration.valid?
      redirect_to :upper_business_type
    else
      redirect_to :upper_contact_detail
    end
  end

  # GET upper-registrations/contact-detail
  def business_type
    @registration = UpperRegistration.new
    session[:upper_reg_params] ||= {}
    session[:upper_reg_params].deep_merge!(upper_reg_params) if params[:upper_registration]

    @registration = UpperRegistration.new(session[:upper_reg_params])
    @registration.current_step = "business_type"
  end

  # POST upper-registrations/contact-detail
  def business_type_update
    @registration = UpperRegistration.new
    session[:upper_reg_params] ||= {}
    session[:upper_reg_params].deep_merge!(upper_reg_params) if params[:upper_registration]

    @registration = UpperRegistration.new(session[:upper_reg_params])
    @registration.current_step = "business_type"

    if @registration.valid?
      redirect_to :upper_business_type
    else
      redirect_to :upper_business_type
    end
  end

  def director_address
  end

  def conviction
  end

  def summary
  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def upper_reg_params
    params.require(:upper_registration).permit(
      :business_name,
      :carrier,
      :broker,
      :dealer)
  end

end
