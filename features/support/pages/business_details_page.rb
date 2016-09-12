module BusinessDetailsPage
  # for sole trader, partnership, public body, charity and authority
  def business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit(companyName: 'Testing Company',
    postcode: 'BS1 5AH', address: 'ENVIRONMENT AGENCY, HORIZON HOUSE, DEANERY ROAD, BRISTOL, BS1 5AH')
    fill_in 'registration_companyName', with: companyName
    fill_in 'sPostcode', with: postcode
    click_button 'find_address'
    #select 'Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH'
    select address
    business_details_page_submit_business_details_page
  end
  # for sole trader, partnership, public body, charity and authority
  def business_details_page_enter_business_or_organisation_details_manual_postcode_and_submit(companyName: 'Test Company',
    houseNumber: '12', line1: 'Deanery Road',
    line2: 'EA Building', townCity: 'Bristol', postcode: 'BS1 5AH')

    click_link 'manual_uk_address'
    fill_in 'registration_companyName', with: companyName
    fill_in 'address_houseNumber', with: houseNumber
    fill_in 'address_addressLine1', with: line1
    fill_in 'address_addressLine2', with: line2
    fill_in 'address_townCity', with: townCity
    fill_in 'address_postcode', with: postcode
    business_details_page_submit_business_details_page
  end
  # for Limited Company only
  def business_details_page_enter_ltd_business_details_manual_postcode_and_submit(companyNo: '02050399',
    companyName: 'Test Company', houseNumber: '12', line1: 'Deanery Road',
    line2: 'EA Building', townCity: 'Bristol', postcode: 'BS1 5AH')

    click_link 'manual_uk_address'
    fill_in 'registration_company_no', with: companyNo
    fill_in 'registration_companyName', with: companyName
    fill_in 'address_houseNumber', with: houseNumber
    fill_in 'address_addressLine1', with: line1
    fill_in 'address_addressLine2', with: line2
    fill_in 'address_townCity', with: townCity
    fill_in 'address_postcode', with: postcode
    business_details_page_submit_business_details_page
  end
  # for Limited Company only
  def business_details_page_enter_ltd_business_details_postcode_lookup_and_submit(companyNo: '02050399',
    companyName: 'Test Company', postcode: 'BS1 5AH',
    address: 'ENVIRONMENT AGENCY, HORIZON HOUSE, DEANERY ROAD, BRISTOL, BS1 5AH')

    fill_in 'registration_company_no', with: companyNo
    fill_in 'registration_companyName', with: companyName
    fill_in 'sPostcode', with: postcode
    click_button 'find_address'
    #select 'Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH'
    select address
    business_details_page_submit_business_details_page
  end

  def business_details_page_submit_business_details_page()
    click_button 'continue'
  end

  # Select a different address (from postcode lookup)
  def business_details_page_change_business_address(postcode: 'BS1 5AH',
      address: 'HARMSEN GROUP, TRIODOS BANK, DEANERY ROAD, BRISTOL, BS1 5AH')

    fill_in 'sPostcode', with: postcode
    click_button 'find_address'
    select address
    business_details_page_submit_business_details_page
  end
end
World(BusinessDetailsPage)
