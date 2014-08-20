class Role
  include Mongoid::Document
  has_and_belongs_to_many :users
  has_and_belongs_to_many :agency_users
  belongs_to :resource, :polymorphic => true
#  belongs_to :users, :polymorphic => true
#  belongs_to :agency_users, :polymorphic => true
  
  field :name, :type => String

  index({
    :name => 1,
    :resource_type => 1,
    :resource_id => 1
  },
  { :unique => true})
  
  # This is the master role list, If these values change they are directly updated in the database, 
  # and any old records will become out of sync unless they have been removed.
  ROLE_TYPES = %w[
    Role_financeBasic
    Role_financeAdmin
    Role_ncccRefund
    Role_ncccPayment
  ]
  
  def self.roles
    ROLE_TYPES
  end
  
  def self.translated_roles    
    list = Array.new
    Role.roles.each do |role|
      item = Array.new
      item << I18n.t('agencyUsers.' + role)
      item << role
      list << item
    end
    list
  end
  
  scopify
end
