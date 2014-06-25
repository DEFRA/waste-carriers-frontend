#Controller for handling the responses received from Worldpay (via the user's browser)

class WorldpayController < ApplicationController

  def success
    @registration = Registration.find(session[:registration_id])
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
