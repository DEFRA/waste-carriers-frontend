#This User class represents an external user, particularly a Waste Carrier who registers with this service.

class User < ActiveRecord::Base
  
  # Note: Devise standard default modules are 
  # :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  # However, We do not want to use :registerable, as registration (i.e. user sign-up) 
  # is done as part of the waste carrier registration flow.
  # We also do not use :rememberable (remember me tokens)

  devise :database_authenticatable, :recoverable, :trackable, :validatable

  def is_admin?
  	false
  end

  def is_agency_user?
    false
  end
  
end
