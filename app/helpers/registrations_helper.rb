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

end
