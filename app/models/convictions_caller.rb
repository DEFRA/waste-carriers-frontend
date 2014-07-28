class ConvictionsCaller
  attr_reader :params

  @@URL = 'http://localhost:9090/convictions/'

  def initialize options={}
    @params = options
  end

  def convicted?
    begin
      json = JSON.parse RestClient.get @@URL, params: @params
      json['isSuspect']
    rescue
      :error_calling_service
    end
  end
end