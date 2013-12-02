module RegistrationsHelper

def validation_for(model, attribute)
  if model.errors[attribute].any?
    # Note: Calling raw() forces the characters to be un-escaped and thus HTML elements can be defined here
    raw("<span class=\"error-text\">#{model.errors.full_messages_for(attribute).first}</span>")
  else
    ""
  end
end

end
