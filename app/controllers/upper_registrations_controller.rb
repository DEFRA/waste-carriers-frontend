class UpperRegistrationsController < ApplicationController

  def business_details
    @registration = UpperRegistration.new
    session[:upper_reg_params] ||= {}
    session[:upper_reg_params].deep_merge!(upper_reg_params) if params[:upper_registration]

    @registration = UpperRegistration.new(session[:upper_reg_params])
    @registration.current_step = "business_details"
  end

  def business_details_update
    session[:upper_reg_params] ||= {}
    session[:upper_reg_params].deep_merge!(upper_reg_params) if params[:upper_registration]

    @registration = UpperRegistration.new(session[:upper_reg_params])
    @registration.current_step = "business_details"

    if @registration.valid?
      logger.info "GOT A VALID REGISTRATION"
      redirect_to :upper_business_details
    elsif @registration.new_record?
      redirect_to :upper_business_details
    end
  end

  def director_address
  end

  def contact_detail
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
