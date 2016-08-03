class ReportsController < ApplicationController
  include RegistrationExportHelper
  include CopyCardsExportHelper

  #We require authentication for all reports and authorisation for some reports.

  before_action :authenticate_agency_user!
  before_action :set_report

  # GET /report/registrations
  def registrations_search
  end

  # POST /report/registrations
  def registrations_search_post
    @report.search_type = :registration

    unless @report.is_new.blank?
      @report.is_new = 'false'

      if @report.valid?

        @report.result_count = 100
        @registrations = search_registrations

        if @registrations.empty?
          @report.errors.add(:base, t('errors.messages.no_results'))
          logger.debug "No registration results found in #{__method__.to_s}"
          render 'registrations_search', :status => '400'
        else
          logger.debug "Rendering #{@registrations.count} registration search results in #{__method__.to_s}"
          render 'registrations_search_results'
        end
      else
        logger.warn "Registrations report filters are not valid in #{__method__.to_s}"
        render 'registrations_search', :status => '400'
      end
    end
  end

  # GET /reports/registrations/results
  def registrations_search_results
    @report.search_type = :registration

    if @report.valid?

      @registrations = search_registrations

      if @registrations.empty?
        @report.errors.add(:base, t('errors.messages.no_results'))
        logger.debug "No registration results found in #{__method__.to_s}"
        render 'registrations_search', :status => '400'
      end
    else
      logger.warn "Registrations report filters are not valid in #{__method__.to_s}"
      render 'registrations_search', :status => '400'
    end

  end

  # POST /reports/registrations/results
  def registrations_export
    @report.search_type = :registration

    if @report.valid?

      @report.result_count = nil
      @registrations = search_registrations

      if @registrations.empty?
        @report.errors.add(:base, t('errors.messages.no_results'))
        logger.debug "No registration results found in #{__method__.to_s}"
        render 'registrations_search', :status => '400'
      else
        logger.debug "Exporting #{@registrations.count} registration search results as csv in #{__method__.to_s}"
        render_registrations_csv("registrations-#{Time.now.strftime("%Y%m%d%H%M%S")}.csv")
      end
    else
      logger.warn "Registrations export filters are not valid in #{__method__.to_s}"
      render 'registrations_search', :status => '400'
    end

  end

  # GET /report/payments
  def payments_search
  end

  # POST /report/payments
  def payments_search_post
    @report.search_type = :payment
    @report.is_new = 'false'

    unless @report.valid?
      logger.warn "Payment report filters are not valid in #{__method__.to_s}"
      render 'payments_search', status: '400'
      return
    end

    @report.result_count = 100
    @registrations = search_payments

    if @registrations.empty?
      @report.errors.add(:base, t('errors.messages.no_results'))
      render 'payments_search', status: '400'
    else
      render 'payments_search_results'
    end

  end

  # POST /reports/payments/results
  def payments_export
    @report.search_type = :payment

    unless @report.valid?
      logger.warn "Payment report filters are not valid in #{__method__.to_s}"
      render 'payments_search', status: '400'
      return
    end

    @report.result_count = nil
    @registrations = search_payments

    if @registrations.empty?
      @report.errors.add(:base, t('errors.messages.no_results'))
      render 'payments_search', status: '400'
    else
      filename = "payments-#{Time.now.strftime("%Y%m%d%H%M%S")}.csv"
      set_export_headers(filename)
      render text: PaymentsExport.new(@report, @registrations).generate_csv
    end

  end

  # GET /report/copy_cards
  def copy_cards_search
  end

  # POST /report/copy_cards
  def copy_cards_search_post
    @report.search_type = :copy_cards

    unless @report.is_new.blank?
      @report.is_new = 'false'

      if @report.valid?

        @report.result_count = 100
        @copy_cards = search_copy_cards

        if @copy_cards.empty?
          @report.errors.add(:base, t('errors.messages.no_results'))
          logger.debug "No copy card results found in #{__method__.to_s}"
          render 'copy_cards_search', :status => '400'
        else
          logger.debug "Rendering #{@copy_cards.count} copy cards search results in #{__method__.to_s}"
          render 'copy_cards_search_results'
        end
      else
        logger.warn "Copy cards report filters are not valid in #{__method__.to_s}"
        render 'copy_cards_search', :status => '400'
      end
    end
  end

  # GET /reports/copy_cards/results
  def copy_cards_search_results
    @report.search_type = :copy_cards

    if @report.valid?

      @copy_cards = search_copy_cards

      if @copy_cards.empty?
        @report.errors.add(:base, t('errors.messages.no_results'))
        logger.debug "No copy card results found in #{__method__.to_s}"
        render 'copy_cards_search', :status => '400'
      end
    else
      logger.warn "Copy cards report filters are not valid in #{__method__.to_s}"
      render 'copy_cards_search', :status => '400'
    end

  end

  # POST /reports/copy_cards/results
  def copy_cards_export
    @report.search_type = :copy_cards

    if @report.valid?

      @report.result_count = nil
      @copy_cards = search_copy_cards

      if @copy_cards.empty?
        @report.errors.add(:base, t('errors.messages.no_results'))
        logger.debug "No copy card results found in #{__method__.to_s}"
        render 'copy_cards_search', :status => '400'
      else
        logger.debug "Exporting #{@copy_cards.count} copy cards search results as csv in #{__method__.to_s}"
        render_copy_cards_csv("copy_cards-#{Time.now.strftime("%Y%m%d%H%M%S")}.csv")
      end
    else
      logger.warn "Copy cards export filters are not valid in #{__method__.to_s}"
      render 'copy_cards_search', :status => '400'
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

      unless params[:copy_cards].nil?
        @report.copy_cards = filter_for_blanks params[:copy_cards].values
      end

    end

    def search_registrations

      return Registration.find_by_params(@report.registration_parameter_args, options = {
          :url => "/query/registrations",
          :format => ""
      })

    end

    def search_payments

      return Registration.find_by_params(@report.payment_parameter_args, options = {
          :url => "/query/payments",
          :format => ""
      })

    end

  def search_copy_cards

    return Registration.find_by_params(@report.copy_cards_parameter_args, options = {
        :url => "/query/copy_cards",
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

  def render_registrations_csv(filename)
    csv_data = CSV.generate({ row_sep: "\r\n", force_quotes: true }) do |csv|
      headers = regexport_get_headers('full')
      csv << headers
      @registrations.each do |registration|
        begin
          reg_data = regexport_get_registration_data('full', registration)
          if registration.lower?
            csv << pad_array_to_match_length(headers, reg_data)
          else
            registration.key_people.each do |person|
              person_data = regexport_get_person_data('full', registration, person)
              csv << reg_data + person_data
            end
          end
        rescue => e
          # Insert a failure message into the CSV
          csv << registration_error(registration)
          Airbrake.notify(e)
          next
        end
      end
    end
    logger.debug 'finished parsing registration data and sending csv output to browser'
    send_data(csv_data, filename: filename)
    logger.debug 'sent registration data. finishing.'
  end

  def render_copy_cards_csv(filename)
    csv_data = CSV.generate({ row_sep: "\r\n", force_quotes: true }) do |csv|
      headers = copy_cards_export_get_headers('full')
      csv << headers
      @copy_cards.each do |copy_card|
        begin
          data = copy_cards_export_get_registration_data('full', copy_card)
          data.each { |data_line| csv << data_line }
        rescue => e
          # Insert a failure message into the CSV
          csv << registration_error(copy_card)
          Airbrake.notify(e)
          next
        end
      end
    end
    logger.debug 'finished parsing copy card data and sending csv output to browser'
    send_data(csv_data, filename: filename)
    logger.debug 'sent copy card data. finishing.'
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
