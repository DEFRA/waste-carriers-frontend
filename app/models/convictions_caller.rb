class ConvictionsCaller
  attr_reader :params

  @@URL = 'http://localhost:9090/convictions/'

  def initialize params={}
    params.assert_valid_keys :name, :dateOfBirth, :companyNumber
    @params = params
  end

  def convicted?
    begin
      json = JSON.parse RestClient.get @@URL, params: @params
      json['isSuspect']
    rescue
      :error_calling_service
    end

    # FIXME for now make this return false until service in place
    false
  end
end