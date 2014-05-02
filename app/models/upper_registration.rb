require 'active_resource'

class UpperRegistration
  include ActiveModel::Model

  attr_accessor :business_name, :full_name, :job_title, :telephone_number, :email_address, :carrier, :broker, :dealer
  attr_writer :current_step

  validates_presence_of :business_name, :full_name, :telephone_number

end
