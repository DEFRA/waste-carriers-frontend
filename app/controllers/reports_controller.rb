class ReportsController < ApplicationController

  #We require authentication for all reports and authorisation for some reports.

  before_action :authenticate_admin_request!

  # GET /report/registrations
  def reportRegistrations

    @report = Report.new(params[:report])

    unless @report.is_new.blank?
      @report.is_new = 'false'

      if @report.valid?

        routes = [ @report.route_digital, @report.route_assisted_digital ]

        @registrations = Registration.find(
          :all,
          :params => {
            :from => @report.from,
            :until => @report.to,
            :route => [ @report.route_digital, @report.route_assisted_digital ],
            :status => @report.statuses,
            :businessType => @report.business_types,
            :ac => params[:email]}
        )
        respond_to do |format|
          format.json { render json: @registrations }
          format.csv
          format.html
        end
      else
        logger.info 'Report filters are not valid'
        render "reportRegistrations", :status => '400'
      end
    end

    # fromParam = params[:from]
    # untilParam = params[:until]
    # @registrations = []
    # @hasErrors = false
    # if !fromParam.nil? and !untilParam.nil?
    #   if fromParam =~ /^\d\d\/\d\d\/\d\d\d\d$/ and untilParam =~ /^\d\d\/\d\d\/\d\d\d\d$/
    #   @registrations = Registration.find(:all, :params => {:from => fromParam, :until => untilParam, :route => params[:route], :status => params[:status], :businessType => params[:businessType], :ac => params[:email]})
    # else
    #   @hasErrors = true
    #   if request.format == 'csv'
    #       redirect_to reports_registrations_path(format: 'html', from: fromParam, until: untilParam, route: params[:route], status: params[:status], businessType: params[:businessType] )
    #     end
    # end
    # end
    # if !@hasErrors
    #   respond_to do |format|
    #     format.json { render json: @registrations }
    #     format.csv
    #     format.html
    #   end
    # end
  end

  # TODO Helper/Shared functions which should be refactored out

  def authenticate_admin_request!
    if is_admin_request?
      authenticate_agency_user!
    end
  end

  def new_action
    session[:report_params] ||= {}
    session[:report_params].deep_merge!(report_params) if params[:report]
    @report = Report.new(session[:report_params])
  end

  private

    def report_params
      params.require(:report).permit(
        :from,
        :to,
        :route_digital,
        :route_assisted_digital)
    end

end