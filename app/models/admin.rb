# Represents an (internal) Administrator.
# Administrators primarily can create and manage other users.

class Admin
  include Mongoid::Document

  # Note: Devise standard default modules are 
  # :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  # However, We do not want to use :registerable, as registration (i.e. user sign-up) 
  # is done as part of the waste carrier registration flow.
  # We also do not use :rememberable (remember me tokens)

  devise :database_authenticatable, :recoverable, :trackable, :validatable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time


  validates_strength_of :password, :with => :email


  def is_admin?
  	true
  end
  
  def is_agency_user?
    false
  end
  
  def self.find_by_email(some_email)
    Admin.find_by(email: some_email)
  end

  def subdomain
    'admin.wastecarrierregistration.service'
  end
  
end
