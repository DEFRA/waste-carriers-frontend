require 'active_resource'

class UpperRegistration < ActiveResource::Base

  attr_accessor :business_name, :carrier, :broker, :dealer
  attr_writer :current_step

end
