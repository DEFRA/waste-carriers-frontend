require 'active_resource'

class UpperRegistration
  include ActiveModel::Model

  attr_accessor :business_name, :full_name, :job_title, :telephone_number, :email_address,
  attr_accessor :carrier_dealer, :broker_dealer, :carrier_broker_dealer
  attr_writer :current_step

  validates_presence_of :business_name, :full_name, :telephone_number

end
