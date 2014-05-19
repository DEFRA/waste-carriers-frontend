# NOTES FOR NEWBIE RUBY/RAILS DEVELOPERS
# Validations: The lambda is not determining whether a value is valid, it is
#   just used to determine whether to actually validate the value at all!

class Discover
  include ActiveModel::Model

  attr_accessor :id, :businessType, :otherBusinesses, :isMainService, :onlyAMF, :constructionWaste, :wasteType_animal, :wasteType_mine, :wasteType_farm, :wasteType_other, :wasteType_none

  # businessType must be present
  validate :validate_businessType

  # otherBusinesses must be present if businessType is present and has a value of "soleTrader" || "partnership" || "limitedCompany" || "publicBody"
  validates_presence_of :otherBusinesses, :if => lambda { |o| !o.businessType.nil? && (o.businessType == "soleTrader" || o.businessType == "partnership" || o.businessType == "limitedCompany" || o.businessType == "publicBody") }

  # isMainService must be present if otherBusinesses is yes
  validates_presence_of :isMainService, :if => lambda { |o| !o.otherBusinesses.nil? && o.otherBusinesses == "yes" }

  # onlyAMF must be present if otherBusinesses is yes
  validates_presence_of :onlyAMF, :if => lambda { |o| !o.otherBusinesses.nil? && o.otherBusinesses == "yes" && !o.isMainService.nil? && o.isMainService == "yes"}

  # construction waste must be present if otherBusinesses is no
  validates_presence_of :constructionWaste, :if => lambda { |o| !o.otherBusinesses.nil? && o.otherBusinesses == "no" }

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
    if wasteType_animal == "0" && wasteType_mine == "0" && wasteType_farm == "0" && wasteType_other == "0" && wasteType_none == "0"
      errors.add(:wasteType, 'must select at least one option')
    end
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

  # Test to see if discovery determines user should register in the Upper Tier
  def isUpper?

    if isUpperBusinessType? \
      && !otherBusinesses.nil? && otherBusinesses == 'no' \
      && !constructionWaste.nil? && constructionWaste == 'yes'
      Rails.logger.info "Is Upper Tier found (otherBusinesses = no, constructionWaste = yes)"
      return true
    elsif isUpperBusinessType? \
      && !otherBusinesses.nil? && otherBusinesses == 'yes' \
      && !isMainService.nil? && isMainService == 'no' \
      && !constructionWaste.nil? && constructionWaste == 'yes'
      Rails.logger.info "Is Upper Tier found (otherBusinesses = yes, isMainService = no, constructionWaste = yes)"
      return true
    elsif isUpperBusinessType? \
      && !otherBusinesses.nil? && otherBusinesses == 'yes' \
      && !isMainService.nil? && isMainService == 'yes' \
      && !onlyAMF.nil? && onlyAMF == 'no'
      Rails.logger.info "Is Upper Tier found (otherBusinesses = yes, isMainService = yes, onlyAMF = no)"
      return true
    else
      Rails.logger.info "Is Upper Tier not found"
      return false
    end

  end

  # Test to see if the user has selected an Upper Tier business type
  def isUpperBusinessType?
    if !businessType.nil? && (businessType == "soleTrader" || businessType == "partnership" || businessType == "limitedCompany" || businessType == "publicBody")
      return true
    else
      return false
    end
  end

end
