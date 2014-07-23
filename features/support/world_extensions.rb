module KnowsTheDomain
  def my_email_address
    @my_email_address ||= 'joe@grades.co.uk'
  end

  def my_password
    @my_password ||= 'password123'
  end

  def my_unrecognised_postcode
    @my_unrecognised_postcode ||= 'S015 OHX'
  end

  def agency_email_address
    @agency_email_address ||= 'user@agency.gov.uk'
  end

  def agency_password
    @agency_password ||= 'secret123'
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
end

World(KnowsTheDomain)