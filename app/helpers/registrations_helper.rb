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
	d = Date.parse(dateString)
	day = d.mday
	myExt = 'th'
	if day == 1 || day == 21 || day == 31
	  myExt = 'st'
	elsif day == 2 || day == 22
	  myExt = 'nd'
	end
	d.strftime('%A %-d'+myExt+' %B %Y')
end

def format_address(model)
  if model.postcode.nil?
    # Print International address
    "#{h(model.streetLine1)}<br />#{h(model.streetLine2)}<br />#{h(model.streetLine3)}<br />#{h(model.streetLine4)}<br />#{h(model.country)}".html_safe
  else
    if model.streetLine2 != ""
      # Print UK Address Including Street line 2 (as its optional but been populated)
      "#{h(model.houseNumber)} #{h(model.streetLine1)}<br />#{h(model.streetLine2)}<br />#{h(model.townCity)}<br />#{h(model.postcode)}".html_safe
    else
      # Print UK Address
      "#{h(model.houseNumber)} #{h(model.streetLine1)}<br />#{h(model.townCity)}<br />#{h(model.postcode)}".html_safe
    end    
  end
end

end
