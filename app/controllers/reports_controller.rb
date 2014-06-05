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

        if @report.format == 'csv'
          render "reportRegistrations.csv"
          #render text: @registrations.fred_wants_this
        elsif @report.format == 'json'
          render json: @registrations.to_json
        elsif @report.format == 'xml'
          render json: @registrations.to_xml
        else
          render "reportRegistrations"
        end
      else
        logger.info 'Report filters are not valid'
        render "reportRegistrations", :status => '400'
      end
    end
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

    def render_csv(filename = nil)
      filename ||= params[:action]
      filename += '.csv'

      if request.env['HTTP_USER_AGENT'] =~ /msie/i
        headers['Pragma'] = 'public'
        headers["Content-type"] = "text/plain"
        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
        headers['Expires'] = "0"
      else
        headers["Content-Type"] ||= 'text/csv'
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
      end

      render "reportRegistrations.csv", :layout => false
    end

    def report_params
      params.require(:report).permit(
        :from,
        :to,
        :route_digital,
        :route_assisted_digital,
        :statuses,
        :business_types,
        :format)
    end

end