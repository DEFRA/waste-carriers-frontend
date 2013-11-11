class Discover
  include ActiveModel::Model
  
  attr_accessor :id, :businessType, :otherBusinesses, :constructionWaste, :wasteType_animal, :wasteType_mine, :wasteType_farm, :wasteType_other
  
  # businessType must be present
  validates_presence_of :businessType
  
  # otherBusinesses must be present if businessType is present and has a value of "soleTrader" || "partnership" || "limitedCompany"
  validates_presence_of :otherBusinesses, :if => lambda { |o| !o.businessType.nil? && (o.businessType == "soleTrader" || o.businessType == "partnership" || o.businessType == "limitedCompany") }
  
  # construction waste must be present if otherBusinesses is no
  validates_presence_of :constructionWaste, :if => lambda { |o| !o.otherBusinesses.nil? && o.otherBusinesses == "no" }
  
  # wastetype must be present if construction waste is no, plus ensure that all other checkboxes are not selected
  validates :wasteType_animal, :if => lambda { |o| !o.constructionWaste.nil? && o.constructionWaste == "no" && o.wasteType_mine == "0" && o.wasteType_farm == "0" && o.wasteType_other == "0"}, format:{with:/\A[1]{1}\Z/, message:"must select at least one option"}
  
  def persisted?
    self.id == 1
  end
  
  def initialize(attributes={})
    super
    @omg ||= true
  end
  
  def isUpper?
    # Check if submission is for upper tier
    # 1. If other businesses is yes
    # 2. If constructionWaste is yes
    # 3. If more than one wasteType is selected
    if otherBusinesses == "yes"
      Rails.logger.info "Is Upper Tier found (otherbusinesses)"
      true
    elsif constructionWaste == "yes"
      Rails.logger.info "Is Upper Tier found (constructionWaste)"
      true
    else 
      # Count number of selected checkboxes
      count = 0
      if wasteType_animal == "1"
        count = count + 1
      end
      if wasteType_mine == "1"
        count = count + 1
      end
      if wasteType_farm == "1"
        count = count + 1
      end
      if wasteType_other == "1"
        count = count + 1
      end
      if count > 1
        Rails.logger.info "Is Upper Tier found (multi wasteType)"
        true
      else
        false
      end
    end
  end
  
end
