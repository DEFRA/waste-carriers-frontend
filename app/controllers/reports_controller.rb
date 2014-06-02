class ReportsController < ApplicationController

  #We require authentication for all reports and authorisation for some reports.

  before_action :authenticate_admin_request!

  # GET /report/registrations
  def reportRegistrations
    fromParam = params[:from]
    untilParam = params[:until]
    @registrations = []
    @hasErrors = false
    if !fromParam.nil? and !untilParam.nil?
      if fromParam =~ /^\d\d\/\d\d\/\d\d\d\d$/ and untilParam =~ /^\d\d\/\d\d\/\d\d\d\d$/
      @registrations = Registration.find(:all, :params => {:from => fromParam, :until => untilParam, :route => params[:route], :status => params[:status], :businessType => params[:businessType], :ac => params[:email]})
    else
      @hasErrors = true
      if request.format == 'csv'
          redirect_to export_registrations_path(format: 'html', from: fromParam, until: untilParam, route: params[:route], status: params[:status], businessType: params[:businessType] )
        end
    end
    end
    if !@hasErrors
      respond_to do |format|
        format.json { render json: @registrations }
        format.csv
        format.html
      end
    end
  end

  # TODO Helper/Shared functions which should be factored out

  def authenticate_admin_request!
    if is_admin_request?
      authenticate_agency_user!
    end
  end

end