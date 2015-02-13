module BusinessDetailsPage
  # for sole trader, partnership, public body, charity and authority
  def enter_business_or_organisation_details_postcode_lookup_and_submit(companyName: 'Test Company',
    postcode: 'BS1 5AH', address: 'ENVIRONMENT AGENCY, HORIZON HOUSE, DEANERY ROAD, BRISTOL, BS1 5AH')

    fill_in 'registration_companyName', with: companyName
    fill_in 'sPostcode', with: postcode
    click_button 'find_address'
    #select 'Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH'
    select address
    submit_business_details_page
  end
  # for sole trader, partnership, public body, charity and authority
  def enter_business_or_organisation_details_manual_postcode_and_submit(companyName: 'Test Company',
    houseNumber: '12', line1: 'Deanery Road',
    line2: 'EA Building', townCity: 'Bristol', postcode: 'BS1 5AH')

    click_link 'manual_uk_address'
    fill_in 'registration_companyName', with: companyName
    fill_in 'registration_houseNumber', with: houseNumber
    fill_in 'registration_streetLine1', with: line1
    fill_in 'registration_streetLine2', with: line2
    fill_in 'registration_townCity', with: townCity
    fill_in 'registration_postcode', with: postcode
    submit_business_details_page
  end
  # for Limited Company only
  def enter_ltd_business_details_manual_postcode_and_submit(companyNo: '02050399',
    companyName: 'Test Company', houseNumber: '12', line1: 'Deanery Road',
    line2: 'EA Building', townCity: 'Bristol', postcode: 'BS1 5AH')

    click_link 'manual_uk_address'
    fill_in 'registration_company_no', with: companyNo
    fill_in 'registration_companyName', with: companyName
    fill_in 'registration_houseNumber', with: houseNumber
    fill_in 'registration_streetLine1', with: line1
    fill_in 'registration_streetLine2', with: line2
    fill_in 'registration_townCity', with: townCity
    fill_in 'registration_postcode', with: postcode
    submit_business_details_page
  end
  # for Limited Company only
  def enter_ltd_business_details_postcode_lookup_and_submit(companyNo: '02050399',
    companyName: 'Test Company', postcode: 'BS1 5AH',
    address: 'ENVIRONMENT AGENCY, HORIZON HOUSE, DEANERY ROAD, BRISTOL, BS1 5AH')

    fill_in 'registration_company_no', with: companyNo
    fill_in 'registration_companyName', with: companyName
    fill_in 'sPostcode', with: postcode
    click_button 'find_address'
    #select 'Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH'
    select address
    submit_business_details_page
  end

  def submit_business_details_page()
    click_button 'continue'
  end
end
World(BusinessDetailsPage)