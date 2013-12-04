require 'active_resource'

class Version < ActiveResource::Base

  #The services URL can be configured in config/application.rb and/or in the config/environments/*.rb files.
  self.site = Rails.configuration.waste_exemplar_services_url
  self.format = :json
  
  schema do
    string :versionDetails
    string :lastBuilt
  end
  
end