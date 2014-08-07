class ConvictionsCaller

  @@URL = 'http://localhost:9290/convictions'

  def initialize params
    validate_params params

    @params = params
  end

  def convicted?
    begin
      json = JSON.parse RestClient.get @@URL, params: @params
      json['matchFound']
    rescue
      :error_calling_service
    end
  end

private

  def validate_params params
    raise_if_no_params params
    raise_if_have_invalid_keys params
  end

  def raise_if_no_params params
    raise if params.empty?
  end

  def raise_if_have_invalid_keys params
    params.assert_valid_keys :name, :dateOfBirth, :companyNumber
  end
end