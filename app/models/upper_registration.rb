require 'active_resource'

class UpperRegistration
  include ActiveModel::Model

  attr_accessor :business_name, :full_name, :job_title, :telephone_number, :email_address, :business_type
  attr_accessor :company_house_number, :alt_full_name, :alt_job_title, :alt_telephone_number, :alt_email_address
  attr_accessor :relevant_conviction
  attr_accessor :carrier_dealer, :broker_dealer, :carrier_broker_dealer
  attr_writer :current_step

end
