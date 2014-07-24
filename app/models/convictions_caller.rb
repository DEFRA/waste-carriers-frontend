class ConvictionsCaller
  attr_reader :params

  def initialize options={}
    @params = options
  end

  def convicted?
    begin
      json = JSON.parse RestClient.get RestClient.get 'http://localhost/convictions', params: @params
      json['suspect']
    rescue
      :error_calling_service
    end
  end
end