#Controller for handling the responses received from Worldpay (via the user's browser)

class WorldpayController < ApplicationController

  include WorldpayHelper

  def success
    #TODO - redirect to some other page after processing/saving the payment
    #redirect_to paid_path
    @registration = Registration.find session[:registration_id]

    process_payment

    next_step = if @registration.assisted_digital?
                  print_path(@registration)
                elsif @registration.user.confirmed?
                  confirmed_path
                else
                  pending_path
                end

    redirect_to next_step

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
    #process_payment
  end

  private

    def process_payment
      orderKey = params[:orderKey] || ''
      paymentAmount = params[:paymentAmount] || ''
      paymentCurrency = params[:paymentCurrency] || ''
      paymentStatus = params[:paymentStatus] || ''
      mac = params[:mac] || ''
      if !validate_worldpay_return_parameters(orderKey,paymentAmount,paymentCurrency,paymentStatus,mac)
        logger.error 'Validation of Worldpay return parameters failed. MAC verification failed!'
        redirect_to worldpay_error_path
        return
      end
      orderCode = orderKey.split('^').at(2)

      now = Time.now.utc.xmlschema
      @payment = Payment.new
      @payment.dateReceived = now
      #We don't nned to set the dateEntered; this is done within the service
      #@payment.dateEntered = now
      # TODO get the user if not yet logged in (still to be activated)
      @payment.updatedByUser = current_any_user
      @payment.amount = paymentAmount
      @payment.currency = paymentCurrency
      @payment.paymentType = 'WORLDPAY'
      @payment.worldPayPaymentStatus = paymentStatus
      @payment.mac_code = mac
      @payment.registrationReference = ''
      @payment.comment = 'Paid via Worldpay'
      @payment.prefix_options[:id] = session[:registration_id]

      if @payment.valid?
        @payment.save!
      else
        logger.error 'Payment is not valid! ' + @payment.errors.messages.to_s
      end
    end

end
