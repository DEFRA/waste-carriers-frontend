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

end
