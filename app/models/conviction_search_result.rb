class ConvictionSearchResult < Ohm::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :match_result
  attribute :matching_system
  attribute :reference
  attribute :matched_name
  attribute :searched_at
  attribute :confirmed
  attribute :confirmed_at
  attribute :confirmed_by

  # Returns a hash representation of the ConvictionSearchResult object.
  # @param none
  # @return  [Hash]  the ConvictionSearchResult object as a hash
  def to_hash
    self.attributes.to_hash
  end

  # Returns a JSON Java/DropWizard API compatible representation of the
  # ConvictionSearchResult object.
  # @param none
  # @return  [String]  the ConvictionSearchResult object in JSON form
  def to_json
    to_hash.to_json
  end

  def add(a_hash)
    a_hash.each do |prop_name, prop_value|
      self.send(:update, { prop_name.to_sym => prop_value })
    end
  end

  # Returns a single string containing both the system name and reference
  # number of conviction match.
  def get_formatted_reference
    result = ''
    unless matching_system.blank? && reference.blank?
      result = format('%s-%s', matching_system, reference)
    end
    result
  end
  
  class << self
    def init(conviction_search_result_hash)
      conviction_search_result = ConvictionSearchResult.create

      conviction_search_result_hash.each do |k, v|
        conviction_search_result.send(:update, { k.to_sym => v })
      end

      conviction_search_result.save
      conviction_search_result
    end

    def search_person_convictions(params)
      # Validate parameters.
      fail if params.empty?
      params.assert_valid_keys [:firstname, :lastname, :dateOfBirth]

      # Perform the convictions search.
      do_convictions_search(
        format(
          '%s/convictions/person',
          Rails.configuration.waste_exemplar_convictions_service_url
        ),
        params
      )
    end

    def search_company_convictions(params)
      # Validate parameters.
      fail if params.empty?
      params.assert_valid_keys [:companyName, :companyNumber]

      # Perform the convictions search.
      do_convictions_search(
        format(
          '%s/convictions/company',
          Rails.configuration.waste_exemplar_convictions_service_url
        ),
        params
      )
    end

    private

    def do_convictions_search(url, params)
      search_result = ConvictionSearchResult.new

      begin
        result = JSON.parse(RestClient.get(url, params: params))
        search_result = ConvictionSearchResult.init(result)
      rescue Exception => e
        Rails.logger.error format('Convictions service error: %s', e.message)
        search_result.match_result = 'UNKNOWN'
        search_result.matching_system = 'ERROR'
        search_result.searched_at = Time.now.to_i
        search_result.confirmed = 'no'
      end

      search_result.save
      search_result
    end
  end
end
