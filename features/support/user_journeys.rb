module CompleteSmartAnswerJourneys
  def complete_smart_answers_for_new_registration_upper_tier(bussiness_type)
    start_new_registration_and_submit('new')
    select_business_type_and_submit(bussiness_type)
    select_other_business_and_submit('registration_otherBusinesses_no')
    select_construction_demolition_and_submit('registration_constructionWaste_yes')
  end
  def complete_smart_answers_for_new_registration_lower_tier_type_business(bussiness_type)
    #for Charity and Waste Collection business type
    start_new_registration_and_submit('new')
    select_business_type_and_submit(bussiness_type)
  end
end
World(CompleteSmartAnswerJourneys)

module SoleTraderJourneys
  def complete_sole_trader_online()
    complete_smart_answers_for_new_registration_upper_tier('registration_businessType_soletrader')
    select_registration_type_and_submit('registration_registrationType_carrier_dealer')
    enter_business_or_organisation_details_manual_postcode_and_submit
    enter_contact_details_and_submit(firstName: 'Nick')
    enter_key_people_details_and_submit
    select_relevant_convictions_and_submit('registration_declaredConvictions_no')
    confirm_registration_and_submit
    enter_email_details_and_submit
    complete_order_pay_by_bank_transfer_and_submit(0)
    complete_offline_payment
    # finish_registration
  end
end
World(SoleTraderJourneys)

module PartnershipJourneys
  def complete_partnership_online()
    complete_smart_answers_for_new_registration_upper_tier('registration_businessType_partnership')
    select_registration_type_and_submit('registration_registrationType_carrier_dealer')
    enter_business_or_organisation_details_manual_postcode_and_submit
    enter_contact_details_and_submit
    enter_key_people_details_and_submit
    select_relevant_convictions_and_submit('registration_declaredConvictions_no')
    confirm_registration_and_submit
    enter_email_details_and_submit
    complete_order_pay_by_bank_transfer_and_submit(0)
    complete_offline_payment
    # finish_registration
  end
end
World(PartnershipJourneys)

module LimitedCompanyJourneys
  def complete_limited_company_online()
    complete_smart_answers_for_new_registration_upper_tier('registration_businessType_limitedcompany')
    select_registration_type_and_submit('registration_registrationType_carrier_dealer')
    enter_ltd_business_details_manual_postcode_and_submit
    enter_contact_details_and_submit
    enter_key_people_details_and_submit
    select_relevant_convictions_and_submit('registration_declaredConvictions_no')
    confirm_registration_and_submit
    enter_email_details_and_submit
    complete_order_pay_by_bank_transfer_and_submit(0)
    complete_offline_payment
    # finish_registration
  end
end
World(LimitedCompanyJourneys)

module PublicBodyJourneys
  def complete_public_body_online()
    complete_smart_answers_for_new_registration_upper_tier('registration_businessType_publicbody')
    select_registration_type_and_submit('registration_registrationType_carrier_dealer')
    enter_business_or_organisation_details_manual_postcode_and_submit
    enter_contact_details_and_submit
    enter_key_people_details_and_submit
    select_relevant_convictions_and_submit('registration_declaredConvictions_no')
    confirm_registration_and_submit
    enter_email_details_and_submit
    complete_order_pay_by_bank_transfer_and_submit(0)
    complete_offline_payment
    # finish_registration
  end
end
World(PublicBodyJourneys)

module CharityJourneys
  def complete_charity_online()
    complete_smart_answers_for_new_registration_lower_tier_type_business('registration_businessType_charity')
    enter_business_or_organisation_details_manual_postcode_and_submit
    enter_contact_details_and_submit
    confirm_registration_and_submit
    enter_email_details_and_submit
  end
end
World(CharityJourneys)

module WasteCollectionJourneys
  def complete_waste_collection_online()
    complete_smart_answers_for_new_registration_lower_tier_type_business('registration_businessType_authority')
    enter_business_or_organisation_details_manual_postcode_and_submit
    enter_contact_details_and_submit
    confirm_registration_and_submit
    enter_email_details_and_submit
  end
end
World(WasteCollectionJourneys)
