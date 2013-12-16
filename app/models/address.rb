require 'active_resource'

class Address < ActiveResource::Base
  #The services URL can be configured in config/application.rb and/or in the config/environments/*.rb files.
  self.site = Rails.configuration.waste_exemplar_addresses_url

  self.format = :json

  #The schema is not strictly necessary for a model based on ActiveRessource, but helpful for documentation
  schema do
    string :moniker
    string :uprn
    string :postcode
    string :partial
    Array :lines
  end

end
