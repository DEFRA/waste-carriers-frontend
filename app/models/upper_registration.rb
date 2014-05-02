require 'active_resource'

class UpperRegistration
  include ActiveModel::Model

  attr_accessor :business_name, :carrier, :broker, :dealer
  attr_writer :current_step

  validates_presence_of :business_name

end
