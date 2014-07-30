module DirectorsHelper
  def first_name_last_name director
    "#{director.first_name} #{director.last_name}"
  end
end