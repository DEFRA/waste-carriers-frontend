module PasswordHelper
  
  # This method is intended to be used as a custom method for ActiveRecord validations.
  def password_must_have_lowercase_uppercase_and_numeric
    has_lowercase = (password =~ /[a-z]/)
    has_uppercase = (password =~ /[A-Z]/)
    has_numeric   = (password =~ /[0-9]/)
    errors.add(:password, I18n.t('errors.messages.weakPassword')) unless (has_lowercase && has_uppercase && has_numeric)
  end
  
end
