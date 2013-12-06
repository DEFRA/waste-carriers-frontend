class Discover
  include ActiveModel::Model
  
  attr_accessor :id, :businessType, :otherBusinesses, :onlyAMF, :constructionWaste, :wasteType_animal, :wasteType_mine, :wasteType_farm, :wasteType_other, :wasteType_none
  
  # businessType must be present
  validate :validate_businessType
  
  # otherBusinesses must be present if businessType is present and has a value of "soleTrader" || "partnership" || "limitedCompany"
  validates_presence_of :otherBusinesses, :if => lambda { |o| !o.businessType.nil? && (o.businessType == "soleTrader" || o.businessType == "partnership" || o.businessType == "limitedCompany") }
  
  # onlyAMF must be present if otherBusinesses is no
  validates_presence_of :onlyAMF, :if => lambda { |o| !o.otherBusinesses.nil? && o.otherBusinesses == "yes" }
  
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
  
  def isUpper?
    # Check if submission is for upper tier
    # 1. If onlyAMF is no
    # 2. If constructionWaste is yes
    if onlyAMF == "no"
      Rails.logger.info "Is Upper Tier found (onlyAMF)"
      true
    elsif constructionWaste == "yes"
      Rails.logger.info "Is Upper Tier found (constructionWaste)"
      true
    else 
      false
    end
  end
  
#  def isUpper?
#    # Check if submission is for upper tier
#    # 1. If other businesses is yes
#    # 2. If constructionWaste is yes
#    # 3. If more than one wasteType is selected
#    if otherBusinesses == "yes"
#      Rails.logger.info "Is Upper Tier found (otherbusinesses)"
#      true
#    elsif constructionWaste == "yes"
#      Rails.logger.info "Is Upper Tier found (constructionWaste)"
#      true
#    else 
#      # Count number of selected checkboxes
#      count = 0
#      if wasteType_animal == "1"
#        count = count + 1
#      end
#      if wasteType_mine == "1"
#        count = count + 1
#      end
#      if wasteType_farm == "1"
#        count = count + 1
#      end
#      if wasteType_other == "1"
#        count = count + 1
#      end
#      if count > 1
#        Rails.logger.info "Is Upper Tier found (multi wasteType)"
#        true
#      else
#        false
#      end
#    end
#  end
  
end
