module RegistrationsHelper

def validation_for(model, attribute)
  if model.errors[attribute].any?
    # Note: Calling raw() forces the characters to be un-escaped and thus HTML elements can be defined here
    raw("<span class=\"error-text\">#{model.errors.full_messages_for(attribute).first}</span>")
  else
    ""
  end
end

def format_date(dateString)
	d = dateString.to_date
	d.strftime('%A ' + d.mday.ordinalize + ' %B %Y')
end

def format_address(model)
  if model.postcode.nil?
    # Print International address
    raw("#{model.streetLine1}<br />#{model.streetLine2}<br />#{model.streetLine3}<br />#{model.streetLine4}<br />#{model.country}")
  else
    if model.streetLine2 != ""
      # Print UK Address Including Street line 2 (as its optional but been populated)
      raw("#{model.houseNumber} #{model.streetLine1}<br />#{model.streetLine2}<br />#{model.townCity}<br />#{model.postcode}")
    else
      # Print UK Address
      raw("#{model.houseNumber} #{model.streetLine1}<br />#{model.townCity}<br />#{model.postcode}")
    end    
  end
end

end
