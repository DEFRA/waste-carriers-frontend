class HomeController < ApplicationController

  def index
  	if Rails.env.development?
  		#redirect_to home_index_path
  	else
  		if is_admin_request?
  		  redirect_to registrations_path
  		else
  		  redirect_to find_path
  		end
  	end
  end

end
