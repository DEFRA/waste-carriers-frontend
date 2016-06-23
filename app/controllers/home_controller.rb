# Default controller for the service, it handles the index (root) page and
# other pages like version and maintenance
class HomeController < ApplicationController

  def index
    if Rails.application.config.show_developer_index_page
      # not redirecting - show the home_index_path
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
            # not redirecting - show the developer index page...
          end
        end
      end
    end
  end

  def version
    @railsVersion = Rails.configuration.application_version

    begin
      @jenkins_build_number = File.read('jenkins_build_number')
    rescue
      @jenkins_build_number = 'not available'
    end

    # Request version from REST api
    @apiVersionObj = Version.find(:one, from: '/version.json')
    unless @apiVersionObj.nil?
      @apiVersion = @apiVersionObj.versionDetails
    end
  end

  def maintenance
    render file: '/public/maintenance_template.html'
  end

  def seed
    if Rails.application.config.show_developer_index_page
      Rails.application.load_seed
      flash[:notice] = 'Database wiped and seeded.'
    end
    redirect_to :back
  end
end
