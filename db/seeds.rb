def create_agency_user(email, password)
  AgencyUser.create(email: email, password: password)
end

def create_admin(email, password)
  Admin.create(email: email, password: password)
end

def create_all_the_users
  password = ENV["WCRS_DEFAULT_PASSWORD"] || "Secret123"

  # Agency super
  create_admin("agency-super@wcr.gov.uk", password)
  # Finance super
  create_admin("finance-super@wcr.gov.uk", password).add_role(:Role_financeSuper, Admin)

  # Standard agency user
  create_agency_user("agency-user@wcr.gov.uk", password)
  # Agency refund payment user
  create_agency_user("agency-refund-payment-user@wcr.gov.uk", password).add_role(:Role_agencyRefundPayment, AgencyUser)
  # Finance basic user
  create_agency_user("finance-user@wcr.gov.uk", password).add_role(:Role_financeBasic, AgencyUser)
  # Finance admin user
  create_agency_user("finance-admin-user@wcr.gov.uk", password).add_role(:Role_financeAdmin, AgencyUser)
end

# Only seed if not running in production or we specifically require it, eg. for Heroku
if !Rails.env.production? || ENV["WCR_ALLOW_SEED"]
  create_all_the_users
end
