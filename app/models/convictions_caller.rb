class ConvictionsCaller

  def initialize params={}
    validate_params(params)

    @params = params
  end

  def convicted?
    begin
      json = JSON.parse RestClient.get url, params: @params
      json['matchFound']
    rescue
      :error_calling_service
    end

    # FIXME for now make this return false until service in place
    false
  end

  def url
    'http://localhost:9290/convictions'
  end

private

  def validate_params(params)
    raise if params.empty?
    params.assert_valid_keys :name, :dateOfBirth, :companyNumber
  end
end