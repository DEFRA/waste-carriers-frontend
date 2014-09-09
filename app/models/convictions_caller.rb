class ConvictionsCaller

  @@URL = 'http://localhost:9290/convictions'
  @@VALID_KEYS = [:name, :dateOfBirth, :companyNumber]

  def initialize params
    validate_params params

    @params = params
  end

  def check_convictions
    result = {}
    begin
      json = JSON.parse RestClient.get @@URL, params: @params
      result = { :result => json['matchFound'], :time_stamp => json['searchTimeStamp'] }
    rescue
      :error_calling_service
    end
    result
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
    params.assert_valid_keys @@VALID_KEYS
  end

end
