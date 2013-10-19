class User < ActiveRecord::Base
  
  # Devise standard default modules are 
  # :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  # We do not use :registerable, as registration (i.e. user sign-up) is done as part of the waste carrier registration flow.

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
end
