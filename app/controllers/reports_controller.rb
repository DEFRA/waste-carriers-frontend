class ReportsController < ApplicationController

  #We require authentication for all reports and authorisation for some reports.

  before_action :authenticate_admin_request!

  # GET /report/registrations
  def registrations_search

    set_report

  end

  def registrations_search_post

    set_report

    unless @report.is_new.blank?
      @report.is_new = 'false'

      if @report.valid?

        set_registrations

        if @registrations.empty?
          @report.errors.add(:base, t('errors.messages.no_results'))
          render 'registrations_search', :status => '400'
        else
          render 'registrations_search_results'
        end
      else
        logger.info 'Report filters are not valid'
        render 'registrations_search', :status => '400'
      end
    end
  end

  def registrations_search_results

    set_report

    if @report.valid?

      set_registrations

      if @registrations.empty?
        @report.errors.add(:base, t('errors.messages.no_results'))
        render 'registrations_search', :status => '400'
      end
    else
      logger.info 'Report filters are not valid'
      render 'registrations_search', :status => '400'
    end

  end

  def registrations_export

    set_report

    if @report.valid?

      set_registrations

      if @registrations.empty?
        @report.errors.add(:base, t('errors.messages.no_results'))
        render 'registrations_search', :status => '400'
      else
        render_registrations_csv("registrations-#{Time.now.strftime("%Y%m%d%H%M%S")}")
      end
    else
      logger.info 'Report filters are not valid'
      render 'registrations_search', :status => '400'
    end

  end

  def authenticate_admin_request!
    if is_admin_request?
      authenticate_agency_user!
    end
  end

  private

    def set_report

      @report = Report.new(params[:report])

      unless params[:routes].nil?
        @report.routes = params[:routes].values
      end

      unless params[:tiers].nil?
        @report.tiers = params[:tiers].values
      end

      unless params[:statuses].nil?
        @report.statuses = params[:statuses].values
      end

      unless params[:business_types].nil?
        @report.business_types = params[:business_types].values
      end

    end

    def set_registrations

      @registrations = Registration.find_by_params(@report.parameter_args, options = {
          :url => "/query/registrations",
          :format => ""
      })

    end

    # This method and the majority of the code in the reportRegistrations view
    # can be attributed to http://stackoverflow.com/a/94626. FasterCSV is now
    # as of Ruby since 1.9 part of the language and not a Gem. ou simply have to
    # require CSV in config/application.rb.
    def render_registrations_csv(filename = nil)
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

      render "registrations_export.csv", :layout => false
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
