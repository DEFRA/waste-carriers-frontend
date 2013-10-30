# Represents an (internal) Administrator.
# Administrators primarily can create and manage other users.

class Admin < ActiveRecord::Base

  devise :database_authenticatable, :recoverable, :trackable, :validatable

  def is_admin?
  	true
  end
  
end
