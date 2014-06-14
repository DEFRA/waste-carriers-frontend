#Controller for handling the responses received from Worldpay (via the user's browser)

class WorldpayController < ApplicationController

  def success
  	#TODO - redirect to some other page after processing/saving the payment
  	#redirect_to paid_path
  end

  def failure
  	#TODO - Process response and edirect...
  end

  def pending
  	#TODO - Process response and edirect...
  end

  def cancel
  	#TODO - Process response and edirect...  	
  end

end
