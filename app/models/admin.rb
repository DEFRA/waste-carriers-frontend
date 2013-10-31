# Represents an (internal) Administrator.
# Administrators primarily can create and manage other users.

class Admin < ActiveRecord::Base

  devise :database_authenticatable, :recoverable, :trackable, :validatable

  def is_admin?
  	true
  end
  
  def is_agency_user?
    false
  end
  
end
