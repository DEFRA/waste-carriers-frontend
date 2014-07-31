module KeyPeopleHelper
  def first_name_last_name key_person
    "#{key_person.first_name} #{key_person.last_name}"
  end
end