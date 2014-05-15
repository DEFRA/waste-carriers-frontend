# NOTES FOR NEWBIE RUBY/RAILS DEVELOPERS
# Validations: The lambda is not determining whether a value is valid, it is
#   just used to determine whether to actually validate the value at all!

class Discover
  include ActiveModel::Model

  attr_accessor :id, :businessType, :otherBusinesses, :isMainService, :onlyAMF, :constructionWaste

  # businessType must be present
  validate :validate_businessType
  validates_presence_of :otherBusinesses, :if => lambda { |o| o.upper_business_type? }
  validates_presence_of :isMainService, :if => lambda { |o| o.otherBusinesses == 'yes' }
  validates_presence_of :onlyAMF, :if => lambda { |o| o.otherBusinesses == 'yes' and o.isMainService == 'yes' }
  validates_presence_of :constructionWaste, :if => lambda { |o| o.otherBusinesses == 'no' }

  def persisted?
    self.id == 1
  end

  def initialize(attributes={})
    super
    @omg ||= true
  end

  def upper_tier?
    return false unless upper_business_type?
    return true if otherBusinesses == 'no' and constructionWaste == 'yes'
    return true if otherBusinesses == 'yes' and isMainService == 'no' and constructionWaste == 'yes'
    return true if otherBusinesses == 'yes' and isMainService == 'yes' and onlyAMF == 'no'
  end

  def upper_business_type?
    businessType.in? ['soleTrader', 'partnership', 'limitedCompany', 'publicBody']
  end

  def validate_businessType
    case businessType
      when ''
        errors.add(:businessType, I18n.t('errors.messages.blank'))
      when 'other'
        errors.add(:businessType, I18n.t('errors.messages.invalid_selection'))
    end
  end
end
