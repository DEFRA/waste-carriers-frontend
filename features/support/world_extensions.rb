module KnowsTheDomain
  def my_email_address
    @my_email_address ||= 'barry@grades.co.uk'
  end

  def my_password
    @my_password ||= 'password123'
  end
end

World(KnowsTheDomain)