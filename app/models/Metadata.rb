# require 'active_resource'

# class MetaData
#   include ActiveModel::Model



class Metadata < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :dateRegistered
  attribute :anotherString
  attribute :lastModified
  attribute :dateActivated
  attribute :status
  attribute :revokedReason
  attribute :route
  attribute :distance

  def set_attribs(a_hash)
    a_hash.each do |prop_name, prop_value|
      Rails.logger.debug "key: #{prop_name}"
      Rails.logger.debug "val: #{prop_value}"
      self.send("#{prop_name}=",prop_value)
    end
  end

end
