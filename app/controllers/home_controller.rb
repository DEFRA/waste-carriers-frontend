class HomeController < ApplicationController

  def index
  	if Rails.env.development?
  		#redirect_to home_index_path
  	else
  		redirect_to find_path
  	end
  end

end
