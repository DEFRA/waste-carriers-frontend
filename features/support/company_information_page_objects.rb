module RegistrationTypePage
  def select_registration_type_and_submit(value)
    choose(value)
    submit_registration_type_page
  end

  def submit_registration_type_page()
    click_button 'continue'
  end
end
World(RegistrationTypePage)

module BusinessDetailsPage
  # for sole trader, partnership, public body, charity and authority
  def enter_business_or_organisation_details_postcode_lookup_and_submit(companyName: 'Test Company',
    postcode: 'BS1 5AH', address: 'ENVIRONMENT AGENCY, HORIZON HOUSE, DEANERY ROAD, BRISTOL, BS1 5AH')

    fill_in 'registration_companyName', with: companyName
    fill_in 'sPostcode', with: postcode
    click_on 'Find UK address'
    #select 'Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH'
    select address
    submit_business_details_page
  end
  # for sole trader, partnership, public body, charity and authority
  def enter_business_or_organisation_details_manual_postcode_and_submit(companyName: 'Test Company',
    houseNumber: '12', line1: 'Deanery Road',
    line2: 'EA Building', townCity: 'Bristol', postcode: 'BS1 5AH')

    click_on 'I want to add an address myself'
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

    click_on 'I want to add an address myself'
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
    click_on 'Find UK address'
    #select 'Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH'
    select address
    submit_business_details_page
  end

  def submit_business_details_page()
    click_button 'continue'
  end
end
World(BusinessDetailsPage)

module ContactDetailsPage
  def enter_contact_details_and_submit(firstName: 'Joe', lastName: 'Bloggs', phoneNumber: '1111111111')

    fill_in 'registration_firstName', with: firstName
    fill_in 'registration_lastName', with: lastName
    fill_in 'registration_phoneNumber', with: phoneNumber
    fill_in 'registration_contactEmail', with: my_email_address
    submit_contact_details_page
  end
  def submit_contact_details_page()
    click_button 'continue'
  end
end
World(ContactDetailsPage)

module KeyPeoplePage
  def enter_key_people_details_and_submit(firstName: 'Joe',
    lastName: 'Bloggs', day: '15', month: '12', year: '1977')

    fill_in 'key_person_first_name', with: firstName
    fill_in 'key_person_last_name', with: lastName
    fill_in 'key_person_dob_day', with: day
    fill_in 'key_person_dob_month', with: month
    fill_in 'key_person_dob_year', with: year
    submit_key_people_page
  end

  def enter_multiple_key_people_details_and_submit(firstName1: 'Joe',
    lastName1: 'Bloggs', day1: '15', month1: '12', year1: '1977',
    firstName2: 'Joe', lastName2: 'Bloggs', day2: '15', month2: '12', year2: '1977')

    fill_in 'key_person_first_name', with: firstName1
    fill_in 'key_person_last_name', with: lastName1
    fill_in 'key_person_dob_day', with: day1
    fill_in 'key_person_dob_month', with: month1
    fill_in 'key_person_dob_year', with: year1
    add_another_key_person
    fill_in 'key_person_first_name', with: firstName2
    fill_in 'key_person_last_name', with: lastName2
    fill_in 'key_person_dob_day', with: day2
    fill_in 'key_person_dob_month', with: month2
    fill_in 'key_person_dob_year', with: year2
    submit_key_people_page
  end

  def delete_first_key_person()

  end

  def add_another_key_person()
    click_on 'add_btn'
  end

  def submit_key_people_page()
    click_button 'continue'
  end
end
World(KeyPeoplePage)

module RelevantConvictionsPage
  def select_relevant_convictions_and_submit(value)
    choose(value)
    submit_relevant_convictions_page
  end

  def submit_relevant_convictions_page()
    click_button 'continue'
  end
end
World(RelevantConvictionsPage)

module RelevantPeoplePage
  def enter_convicted_person_and_submit(firstName1: 'Joe',
    lastName1: 'Bloggs', position: 'Manager', day1: '15', month1: '12', year1: '1977')

    fill_in 'key_person_first_name', with: firstName1
    fill_in 'key_person_last_name', with: lastName1
    fill_in 'key_person_position', with: position
    fill_in 'key_person_dob_day', with: day1
    fill_in 'key_person_dob_month', with: month1
    fill_in 'key_person_dob_year', with: year1
    submit_relevant_people
  end

  def enter_multiple_convicted_people_and_submit(firstName1: 'Joe',
    lastName1: 'Bloggs', position1: 'Manager', day1: '15', month1: '12', year1: '1977',
    firstName2: 'Joe', lastName2: 'Bloggs', position: 'Senior Manager', day2: '15',
    month2: '12', year2: '1977')

    fill_in 'key_person_first_name', with: firstName1
    fill_in 'key_person_last_name', with: lastName1
    fill_in 'key_person_position', with: position1
    fill_in 'key_person_dob_day', with: day1
    fill_in 'key_person_dob_month', with: month1
    fill_in 'key_person_dob_year', with: year1
    add_another_relevant_person
    fill_in 'key_person_first_name', with: firstName2
    fill_in 'key_person_last_name', with: lastName2
    fill_in 'key_person_position', with: position
    fill_in 'key_person_dob_day', with: day2
    fill_in 'key_person_dob_month', with: month2
    fill_in 'key_person_dob_year', with: year2
    submit_relevant_people
  end

  def add_another_relevant_person()
    click_on 'add_btn'
  end

  def submit_relevant_people()
    click_button 'continue'
  end

end
World(RelevantPeoplePage)
