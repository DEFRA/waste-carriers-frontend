#Controller for handling the responses received from Worldpay (via the user's browser)

class WorldpayController < ApplicationController

  include WorldpayHelper

  def success
  	#TODO - redirect to some other page after processing/saving the payment
  	#redirect_to paid_path
    @registration = Registration.find(session[:registration_id])
    process_payment
  end

  def failure
  	#TODO - Process response and edirect...
    process_payment
  end

  def pending
  	#TODO - Process response and edirect...
    process_payment
  end

  def cancel
  	#TODO - Process response and edirect...  	
    process_payment
  end

  private

    def process_payment
      orderKey = params[:orderKey] || ''
      paymentAmount = params[:paymentAmount] || ''
      paymentCurrency = params[:paymentCurrency] || ''
      paymentStatus = params[:paymentStatus] || ''
      mac = params[:mac] || ''
      if !validate_worldpay_return_parameters(orderKey,paymentAmount,paymentCurrency,paymentStatus,mac)
        redirect_to worldpay_error_path
      end
    end
end
