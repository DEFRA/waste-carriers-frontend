# NOTES FOR NEWBIE RUBY/RAILS DEVELOPERS
# Validations: The lambda is not determining whether a value is valid, it is
#   just used to determine whether to actually validate the value at all!

class Discover
  include ActiveModel::Model

  attr_accessor :id, :businessType, :otherBusinesses, :isMainService, :onlyAMF, :constructionWaste, :wasteType_animal, :wasteType_mine, :wasteType_farm, :wasteType_other, :wasteType_none

  # businessType must be present
  validate :validate_businessType

  # otherBusinesses must be present if businessType is present and has a value of "soleTrader" || "partnership" || "limitedCompany" || "publicBody"
  validates_presence_of :otherBusinesses, :if => lambda { |o| o.upper_business_type? }

  # isMainService must be present if otherBusinesses is yes
  validates_presence_of :isMainService, :if => lambda { |o| o.otherBusinesses == 'yes' }

  # onlyAMF must be present if otherBusinesses is yes
  validates_presence_of :onlyAMF, :if => lambda { |o| o.otherBusinesses == 'yes' and o.isMainService == 'yes' }

  # construction waste must be present if otherBusinesses is no
  validates_presence_of :constructionWaste, :if => lambda { |o| o.otherBusinesses == 'no' }

  # wastetype must be present if construction waste is no, plus ensure that all other checkboxes are not selected
  # Remove waste type validation as field removed
  #validate :validate_not_apply, :if => lambda { |o| !o.constructionWaste.nil? && o.constructionWaste == "no" }

  def validate_not_apply
    if wasteType_none == "1"
      if wasteType_animal == "1" || wasteType_mine == "1" || wasteType_farm == "1" || wasteType_other == "1"
        errors.add(:wasteType, 'cannot contain multiple selections if you do not carry waste regularly')
      else
        errors.add(:wasteType, 'identified that you do not carry waste regularly therefore you do not need to register')
      end
    end

    errors.add(:wasteType, 'must select at least one option') if [wasteType_animal, wasteType_mine, wasteType_farm, wasteType_other, wasteType_none].all? { |parameter| parameter == '0' }
  end

  def persisted?
    self.id == 1
  end

  def initialize(attributes={})
    super
    @omg ||= true
  end

  def validate_businessType
    if businessType == ""
      Rails.logger.debug 'businessType is empty'
      errors.add(:businessType, I18n.t('errors.messages.blank') )
    elsif businessType == "other"
      Rails.logger.debug 'businessType is other thus registration not applicable'
      errors.add(:businessType, I18n.t('errors.messages.invalid_selection') )
    end
  end

  def upper_tier?
    return false unless upper_business_type?
    return true if otherBusinesses.inquiry.no? and constructionWaste.inquiry.yes?
    return true if otherBusinesses.inquiry.yes? and isMainService.inquiry.no? and constructionWaste.inquiry.yes?
    return true if otherBusinesses.inquiry.yes? and isMainService.inquiry.yes? and onlyAMF.inquiry.no?
  end

  def upper_business_type?
    businessType.in? ['soleTrader', 'partnership', 'limitedCompany', 'publicBody']
  end

end
