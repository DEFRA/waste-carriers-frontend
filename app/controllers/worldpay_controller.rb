#Controller for handling the responses received from Worldpay (via the user's browser)

class WorldpayController < ApplicationController

  def success
    redirect_to pending_path
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
