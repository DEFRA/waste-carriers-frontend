#This User class represents an external user, particularly a Waste Carrier who registers with this service.

class User
  include Mongoid::Document
  store_in session: 'users'

  include PasswordHelper

  # Note: Devise standard default modules are
  # :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  # However, We do not want to use :registerable, as registration (i.e. user sign-up)
  # is done as part of the waste carrier registration flow.
  # We also do not use :rememberable (remember me tokens)

  devise :database_authenticatable, :recoverable, :trackable, :validatable, :confirmable, :lockable

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
  field :confirmation_token,   :type => String
  field :confirmed_at,         :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  field :locked_at,       :type => Time

  # We need to know the tier in the confirmation email we send, however as Devise
  # handles it all 'auto-magically' we only get to see the user passed as the resource to the
  # email template. There seems no way we can break into the flow and pass our own variables
  # to the temaplate, hence we add it as an attribute on the user object
  attr_accessor :current_tier

  validates :password, presence: true, length: { in: 8..128 }
  validate :password_must_have_lowercase_uppercase_and_numeric

  def confirmed?
    confirmed_at_present?
  end

  def is_admin?
    false
  end

  def is_agency_user?
    false
  end

  def self.find_by_email(some_email)
    User.find_by(email: some_email)
  end

  def self.find_by_id(some_id)
    User.find(some_id)
  end

  def subdomain
    Rails.application.config.waste_exemplar_frontend_public_subdomain
  end

private

  def confirmed_at_present?
    confirmed_at?
  end

end
