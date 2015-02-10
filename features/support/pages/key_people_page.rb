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