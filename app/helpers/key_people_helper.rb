module KeyPeopleHelper

  def first_name_last_name key_person
    "#{key_person.first_name} #{key_person.last_name}"
  end

  def first_name_last_name_position key_person
    "#{key_person.first_name} #{key_person.last_name} | #{key_person.position}"
  end

  def contains_relevant_people? key_people
    key_people.each do |person|
      if person.person_type == 'RELEVANT'
        return true
      end
    end
    return false
  end

end