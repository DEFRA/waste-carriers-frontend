require 'active_resource'

class Report
  include ActiveModel::Model

  attr_accessor :from, :to, :route_digital, :route_assisted_digital

end