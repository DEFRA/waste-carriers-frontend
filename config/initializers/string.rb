class String

  # Code below is attributed to http://stackoverflow.com/a/7085090
  def is_date?
    temp = self.gsub(/[-.\/]/, '')
    ['%m%d%Y','%m%d%y','%M%D%Y','%M%D%y'].each do |f|
    begin
      return true if Date.strptime(temp, f)
        rescue
         #do nothing
      end
    end

    return false
  end

end