module KnowsTheDomain
  def my_email_address
    @my_email_address ||= 'joe@grades.co.uk'
  end

  def my_password
    @my_password ||= 'Password123'   # Keep this in-sync with the value in data_creation.rb
  end

  def my_unrecognised_postcode
    @my_unrecognised_postcode ||= 'BS1 4PW'
  end
  
  def my_company_name
    @my_company_name ||= 'Bespoke'
  end

  def agency_email_address
    @agency_email_address ||= 'user@agency.gov.uk'
  end

  def agency_password
    @agency_password ||= 'Secret123'
  end

  def my_finance_admin_user
    @my_finance_admin_user ||= FactoryGirl.create :finance_admin_user
  end

  def my_finance_basic_user
    @my_finance_basic_user ||= FactoryGirl.create :finance_basic_user
  end

  def my_agency_refund_user
    @my_agency_refund_user ||= FactoryGirl.create :agency_refund_user
  end

  def my_admin
    @my_admin ||= FactoryGirl.create :admin
  end

  def my_agency_user
    @my_agency_user ||= FactoryGirl.create :agency_user
  end

  def my_user
    @my_user ||= FactoryGirl.create :user
  end

  def do_short_pause_for_email_delivery
    # capybara-email recommends forcing a sleep prior to trying to read any
    # email after an asynchronous event.
    sleep 0.2
  end

  def repopulate_database_with_IR_data
    # Manually force a repopulation of IR data in database
    RestClient.post Rails.configuration.waste_exemplar_services_admin_url +
      '/tasks/ir-repopulate', content_type: :json, accept: :json
  end
end

World(KnowsTheDomain)
