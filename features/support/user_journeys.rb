module SoleTraderJourneys
  def complete_sole_trader_online()
    go_to_start_page
    start_page_select_new
    start_page_submit
    business_type_page_select_sole_trader
    business_type_page_submit
    other_businesses_page_select_no
    other_businesses_page_submit
    construction_demolition_page_select_yes
    construction_demolition_page_submit
    registration_type_page_select_carrier_dealer
    registration_type_page_submit
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
    go_to_start_page
    start_page_select_new
    start_page_submit
    business_type_page_select_partnership
    business_type_page_submit
    other_businesses_page_select_no
    other_businesses_page_submit
    construction_demolition_page_select_yes
    construction_demolition_page_submit
    registration_type_page_select_carrier_dealer
    registration_type_page_submit
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
    go_to_start_page
    start_page_select_new
    start_page_submit
    business_type_page_select_limited_company
    business_type_page_submit
    other_businesses_page_select_no
    other_businesses_page_submit
    construction_demolition_page_select_yes
    construction_demolition_page_submit
    registration_type_page_select_carrier_dealer
    registration_type_page_submit
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
    go_to_start_page
    start_page_select_new
    start_page_submit
    business_type_page_select_public_body
    business_type_page_submit
    other_businesses_page_select_no
    other_businesses_page_submit
    construction_demolition_page_select_yes
    construction_demolition_page_submit
    registration_type_page_select_carrier_dealer
    registration_type_page_submit
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
    go_to_start_page
    start_page_select_new
    start_page_submit
    business_type_page_select_charity
    business_type_page_submit
    enter_business_or_organisation_details_manual_postcode_and_submit
    enter_contact_details_and_submit
    confirm_registration_and_submit
    enter_email_details_and_submit
  end
end
World(CharityJourneys)

module WasteCollectionJourneys
  def complete_waste_collection_online()
    go_to_start_page
    start_page_select_new
    start_page_submit
    business_type_page_select_authority
    business_type_page_submit
    enter_business_or_organisation_details_manual_postcode_and_submit
    enter_contact_details_and_submit
    confirm_registration_and_submit
    enter_email_details_and_submit
  end
end
World(WasteCollectionJourneys)
