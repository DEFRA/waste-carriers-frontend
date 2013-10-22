class User < ActiveRecord::Base
  
  # Devise standard default modules are 
  # :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  # We do not want to use :registerable, as registration (i.e. user sign-up) is done as part of the waste carrier registration flow.
  # We also do not use :rememberable (remember me tokens)
  # However, it seems we need :registerable for the Edit Profile link to work (???)

  devise :database_authenticatable, :recoverable, :trackable, :validatable
end
