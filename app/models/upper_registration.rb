require 'active_resource'

class UpperRegistration
  include ActiveModel::Model

  attr_accessor :business_name, :postcode, :first_name, :last_name, :job_title, :telephone_number, :email_address, :business_type
  attr_accessor :company_house_number, :alt_first_name, :alt_last_name, :alt_job_title, :alt_telephone_number, :alt_email_address
  attr_accessor :relevant_conviction, :copy_cards, :payment_method, :confirmed_declaration
  attr_writer :current_step

end
