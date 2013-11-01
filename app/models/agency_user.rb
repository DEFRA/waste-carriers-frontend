#Represents an 'internal' agency user such as an NCCC worker or other (except Administrators).

class AgencyUser < ActiveRecord::Base

  devise :database_authenticatable, :recoverable, :trackable, :validatable

  def is_admin?
  	false
  end
  
  def is_agency_user?
    true
  end
end
