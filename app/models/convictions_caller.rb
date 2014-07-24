class ConvictionsCaller
  attr_reader :params

  def initialize options={}
    @params = options
  end

  def convicted?
    begin
      json = JSON.parse RestClient.get 'http://localhost/convictions', params: @params
      json['isSuspect']
    rescue
      :error_calling_service
    end
  end
end