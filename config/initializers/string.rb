class String

  # Code below is attributed to http://stackoverflow.com/a/7085090
  def is_date?
    temp = self.gsub(/[-.\/]/, '')
    ['%d%m%Y','%d%m%y','%D%M%Y','%D%M%y'].each do |f|
      begin
        return true if Date.strptime(temp, f)
      rescue
       #do nothing
      end
    end

    return false
  end

end
