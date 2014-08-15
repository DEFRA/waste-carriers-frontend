module OrderHelper

  def showRegistrationFee? renderType
    renderType.eql? Order.new_registration_identifier
  end
  
  def showEditFee? renderType
    renderType.eql? Order.edit_registration_identifier
  end
  
  def showRenewalFee? renderType
    renderType.eql? Order.renew_registration_identifier
  end
  
  def showCopyCards? renderType
    renderType.eql? Order.new_registration_identifier or renderType.eql? Order.extra_copycards_identifier
  end
  
end