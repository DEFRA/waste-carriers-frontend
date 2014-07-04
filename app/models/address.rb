

require 'active_resource'

class Address < ActiveResource::Base
  #The services URL can be configured in config/application.rb and/or in the config/environments/*.rb files.

  self.site = Rails.configuration.waste_exemplar_addresses_url

  self.format = :json

  #The schema is not strictly necessary for a model based on ActiveResource, but helpful for documentation
  schema do
    string :moniker
    string :uprn
    string :postcode
    string :partial
    Array :lines
  end




=begin


class Address

  ADDRESS_LOOKUP_URL =   "#{Rails.configuration.waste_exemplar_addresses_url}/addresses.json"
  MONIKER_LOOKUP_URL =   "#{Rails.configuration.waste_exemplar_addresses_url}/addresses/"

  def initialize(postcode=nil)
    @search_postcode = postcode if postcode
    Rails.logger.debug "postcode: #{ @search_postcode}"
  end

  def lookup(postcode=nil)

    if @search_postcode
      response = RestClient.get  ADDRESS_LOOKUP_URL,  {params: {postcode: @search_postcode}, :accept => :json}
    end

    if postcode
      response =RestClient.get  ADDRESS_LOOKUP_URL,  {params: {postcode: postcode},:accept => :json}
    end

    Rails.logger.debug "services responded: #{response.code}"
    Rails.logger.debug "services body: #{response.body}"
    address_list = response.body.tr('[]', '').split('}')

    addresses = []
    address_list.each do |entry|
      entry.tr!('{', '') #get rid off curly bracket
 Rails.logger.debug entry.to_s
      h = {}
      entry.split(',').each do |pair|
        pair.tr!('"', '') #get rid off double quotes
        key,value = pair.split(/:/)
        h[key] = value
      end

      addresses << h

    end

#replace pipes with percentages, as required by address API
addresses.each do |a|
   Rails.logger.debug  a['moniker'].tr('|', '%')
end

    mon = addresses[1]['moniker'].tr('|', '%')
     Rails.logger.debug mon
     url = "#{MONIKER_LOOKUP_URL}#{mon}.json"
     Rails.logger.debug url
   response =RestClient.get  url
    Rails.logger.debug "moniker responded: #{response.code}"
    Rails.logger.debug "moniker body: #{response.body}"
  end  #method



=end





  def streetLine1
    if lines && lines.size > 0
      lines[0]
    else
      ""
    end
  end

  def streetLine2
    if lines && lines.size > 1
      lines[1]
    else
      ""
    end
  end

  def townCity
    if lines && lines.size > 2
      lines[2]
    else
      ""
    end
  end

end #class
