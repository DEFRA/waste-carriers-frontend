module RelevantPeoplePage
  def relevant_people_page_enter_convicted_person_and_submit(firstName1: 'Joe',
    lastName1: 'Bloggs', position: 'Manager', day1: '15', month1: '12', year1: '1977')

    fill_in 'key_person_first_name', with: firstName1
    fill_in 'key_person_last_name', with: lastName1
    fill_in 'key_person_position', with: position
    fill_in 'key_person_dob_day', with: day1
    fill_in 'key_person_dob_month', with: month1
    fill_in 'key_person_dob_year', with: year1
    relevant_people_page_submit_relevant_people
  end

  def relevant_people_page_enter_multiple_convicted_people_and_submit(firstName1: 'Joe',
    lastName1: 'Bloggs', position1: 'Manager', day1: '15', month1: '12', year1: '1977',
    firstName2: 'Joe', lastName2: 'Bloggs', position: 'Senior Manager', day2: '15',
    month2: '12', year2: '1977')

    fill_in 'key_person_first_name', with: firstName1
    fill_in 'key_person_last_name', with: lastName1
    fill_in 'key_person_position', with: position1
    fill_in 'key_person_dob_day', with: day1
    fill_in 'key_person_dob_month', with: month1
    fill_in 'key_person_dob_year', with: year1
    relevant_people_page_add_another_relevant_person
    fill_in 'key_person_first_name', with: firstName2
    fill_in 'key_person_last_name', with: lastName2
    fill_in 'key_person_position', with: position
    fill_in 'key_person_dob_day', with: day2
    fill_in 'key_person_dob_month', with: month2
    fill_in 'key_person_dob_year', with: year2
    relevant_people_page_submit_relevant_people
  end

  def relevant_people_page_add_another_relevant_person()
    click_button 'add_btn'
  end

  def relevant_people_page_submit_relevant_people()
    click_button 'continue'
  end

end
World(RelevantPeoplePage)