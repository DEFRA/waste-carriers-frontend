class ReportsController < ApplicationController

  #We require authentication for all reports and authorisation for some reports.

  before_action :authenticate_admin_request!

  # GET /report/registrations
  def registrations_search
    set_report
  end

  # POST /report/registrations
  def registrations_search_post

    set_report
    @report.search_type = :registration

    unless @report.is_new.blank?
      @report.is_new = 'false'

      if @report.valid?

        @registrations = search_registrations

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

  # GET /reports/registrations/results
  def registrations_search_results

    set_report
    @report.search_type = :registration

    if @report.valid?

      @registrations = search_registrations

      if @registrations.empty?
        @report.errors.add(:base, t('errors.messages.no_results'))
        render 'registrations_search', :status => '400'
      end
    else
      logger.info 'Report filters are not valid'
      render 'registrations_search', :status => '400'
    end

  end

  # POST /reports/registrations/results
  def registrations_export

    set_report
    @report.search_type = :registration

    if @report.valid?

      @registrations = search_registrations

      if @registrations.empty?
        @report.errors.add(:base, t('errors.messages.no_results'))
        render 'registrations_search', :status => '400'
      else
        render_registrations_csv("registrations-#{Time.now.strftime("%Y%m%d%H%M%S")}")
      end
    else
      logger.info 'Search filters are not valid'
      render 'registrations_search', :status => '400'
    end

  end

  # GET /report/payments
  def payments_search
    set_report
  end

  # POST /report/payments
  def payments_search_post

    set_report
    @report.search_type = :payment

    unless @report.is_new.blank?
      @report.is_new = 'false'

      if @report.valid?

        @registrations = search_payments

        if @registrations.empty?
          @report.errors.add(:base, t('errors.messages.no_results'))
          render 'payments_search', :status => '400'
        else
          render 'payments_search_results'
        end
      else
        logger.info 'Search filters are not valid'
        render 'payments_search', :status => '400'
      end
    end
  end

  # POST /reports/payments/results
  def payments_export

    set_report
    @report.search_type = :payment

    if @report.valid?

      @registrations = search_payments

      if @registrations.empty?
        @report.errors.add(:base, t('errors.messages.no_results'))
        render 'payments_search', :status => '400'
      else
        render_payments_csv("payments-#{Time.now.strftime("%Y%m%d%H%M%S")}")
      end
    else
      logger.info 'Search filters are not valid'
      render 'payments_search', :status => '400'
    end

  end

  private

    def authenticate_admin_request!
      if is_admin_request?
        authenticate_agency_user!
      end
    end

    def set_report

      @report = Report.new(params[:report])

      unless params[:routes].nil?
        @report.routes = filter_for_blanks params[:routes].values
      end

      unless params[:tiers].nil?
        @report.tiers = filter_for_blanks params[:tiers].values
      end

      unless params[:statuses].nil?
        @report.statuses = filter_for_blanks params[:statuses].values
      end

      unless params[:business_types].nil?
        @report.business_types = filter_for_blanks params[:business_types].values
      end

      unless params[:payment_statuses].nil?
        @report.payment_statuses = filter_for_blanks params[:payment_statuses].values
      end

      unless params[:payment_types].nil?
        @report.payment_types = filter_for_blanks params[:payment_types].values
      end

      unless params[:charge_types].nil?
        @report.charge_types = filter_for_blanks params[:charge_types].values
      end

    end

    def search_registrations

      return Registration.find_by_params(@report.registration_parameter_args, options = {
          :url => "/query/registrations",
          :format => ""
      })

    end

    def search_payments

      return Registration.find_by_params(@report.registration_parameter_args, options = {
          :url => "/query/payments",
          :format => ""
      })

    end

    def filter_for_blanks(values)

      filtered = []

      unless values.nil?
        filtered = values.reject(&:blank?)
      end

      unless filtered
        filtered = []
      end

      filtered

    end

    def render_registrations_csv(filename = nil)
      filename ||= params[:action]
      filename += '.csv'

      set_export_headers filename

      render "registrations_export.csv", :layout => false
    end

    def render_payments_csv(filename = nil)
      filename ||= params[:action]
      filename += '.csv'

      set_export_headers filename

      render "payments_export.csv", :layout => false
    end

    # This method and the majority of the code in the reportRegistrations view
    # can be attributed to http://stackoverflow.com/a/94626. FasterCSV is now
    # as of Ruby since 1.9 part of the language and not a Gem. You simply have to
    # require CSV in config/application.rb.
    def set_export_headers(filename = nil)

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

    end

    def report_params
      params.require(:report).permit(
        :from,
        :to,
        :routes,
        :tiers,
        :statuses,
        :business_types,
        :payment_statuses,
        :payment_types,
        :charge_types)
    end

end
