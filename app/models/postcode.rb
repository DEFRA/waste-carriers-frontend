class Postcode

  # Validate a UK postcode using a modified version of the official 
  # regular expression provided by 
  # http://www.govtalk.gov.uk/gdsc/schemaHtml/bs7666-v2-0-xsd-PostCodeType.htm
  #
  # @param [String] postcode the postcode to validate
  # @return [Boolean] true if the postcode is valid, false if not
  def self.is_valid_postcode?(postcode)
    postcode =~ /^\s*((GIR\s*0AA)|((([A-PR-UWYZ][0-9]{1,2})|(([A-PR-UWYZ][A-HK-Y][0-9]{1,2})|(([A-PR-UWYZ][0-9][A-HJKSTUW])|([A-PR-UWYZ][A-HK-Y][0-9][ABEHMNPRVWXY]))))\s*[0-9][ABD-HJLNP-UW-Z]{2}))\s*$/i
  end

end
