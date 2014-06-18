class HomeController < ApplicationController

  def index
  	if Rails.application.config.show_developer_index_page
  		#not redirecting - show the home_index_path
  	else
  		if is_admin_request?
  		  redirect_to registrations_path
  		else
        if user_signed_in?
          redirect_to userRegistrations_path(current_user)
        elsif agency_user_signed_in?
          redirect_to registrations_path
        elsif admin_signed_in?
          redirect_to agency_users_path
        else
          if Rails.env.production?
            redirect_to find_path
          else
            #not redirecting - show the developer index page...
          end
        end
  		end
  	end
  end #end index

  def version
    @railsVersion = Rails.configuration.application_version

    # Request version from REST api
    @apiVersionObj = Version.find(:one, :from => "/version.json" )
    if !@apiVersionObj.nil?
      logger.debug 'Version info, version number:' + @apiVersionObj.versionDetails + ' lastBuilt: ' + @apiVersionObj.lastBuilt
      @apiVersion = @apiVersionObj.versionDetails
    end

#    render :layout => false
  end

end
