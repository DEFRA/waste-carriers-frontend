# Represents a Conviction record, as stored in ElasticSearch.

require 'elasticsearch/persistence/model'

class Conviction
  include Elasticsearch::Persistence::Model
  
  attribute :name, String
  attribute :dateOfBirth, Date
  attribute :companyNumber, String
  attribute :systemFlag, String
  attribute :incidentNumber, String
end
