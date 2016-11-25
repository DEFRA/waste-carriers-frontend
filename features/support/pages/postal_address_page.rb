# Helper used in testing for working with the Postal Address page.
module PostalAddressPage
  def go_to_postal_address_page
    visit postal_address_path
  end

  def postal_address_page?
    expect(page).to have_css 'div[data-journey$="postal-address"]'
  end

  def postal_address_page_complete_form(
    first_name: 'Joe',
    last_name: 'Grades',
    house_number: '44',
    line_1: 'Broad Street',
    line_2: 'City Centre',
    line_3: '',
    line_4: '',
    town_city: 'Bristol',
    postcode: 'BS1 2EP',
    country: 'United Kingdom',
    submit: 'true')

    fill_in 'address_firstName', with: first_name
    fill_in 'address_lastName', with: last_name
    fill_in 'address_houseNumber', with: house_number
    fill_in 'address_addressLine1', with: line_1
    fill_in 'address_addressLine2', with: line_2
    fill_in 'address_addressLine3', with: line_3
    fill_in 'address_addressLine4', with: line_4
    fill_in 'address_townCity', with: town_city
    fill_in 'address_postcode', with: postcode
    fill_in 'address_country', with: country

    postal_address_page_submit if submit
  end

  def postal_address_page_submit
    click_button 'continue'
  end
end
World(PostalAddressPage)
