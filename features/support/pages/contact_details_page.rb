
module ContactDetailsPage
  def contact_details_page_enter_contact_details_and_submit(firstName: 'Joe', lastName: 'Bloggs', phoneNumber: '1111111111')

    fill_in 'registration_firstName', with: firstName
    fill_in 'registration_lastName', with: lastName
    fill_in 'registration_phoneNumber', with: phoneNumber
    fill_in 'registration_contactEmail', with: my_email_address
    submit_contact_details_page
  end

    def contact_details_page_enter_ad_contact_details_and_submit(firstName: 'Joe', lastName: 'Bloggs', phoneNumber: '1111111111')

    fill_in 'registration_firstName', with: firstName
    fill_in 'registration_lastName', with: lastName
    fill_in 'registration_phoneNumber', with: phoneNumber
    submit_contact_details_page
  end

  def submit_contact_details_page()
    click_button 'continue'
  end
end
World(ContactDetailsPage)