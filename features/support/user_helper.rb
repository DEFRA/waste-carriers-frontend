# Provides various methods that are used in the Cucumber tests, and allow a single test-step
# definition to handle external, internal and admin users in the same way.

module UserHelper
  # Returns the FactoryGirl mock user object for the specified user-type name.
  def get_factorygirl_user_for_user_type(friendly_user_type_name)
    case friendly_user_type_name
    when 'External User'
      my_user
    when 'Internal User'
      my_agency_user
    when 'Admin User'
      my_admin
    else
      throw 'Unknown friendly_user_type_name specified'
    end
  end

  # Returns an object from the database for the test user with the specified user-type name.
  def get_database_object_for_user_type(friendly_user_type_name)
    case friendly_user_type_name
    when 'External User'
      User.find_by(email: my_user.email)
    when 'Internal User'
      AgencyUser.find_by(email: my_agency_user.email)
    when 'Admin User'
      Admin.find_by(email: my_admin.email)
    else
      throw 'Unknown friendly_user_type_name specified'
    end
  end

  # Returns the path / URL for a new session of the specified user type.
  def get_new_session_path_for_user_type(friendly_user_type_name)
    case friendly_user_type_name
    when 'External User'
      new_user_session_path
    when 'Internal User'
      new_agency_user_session_path
    when 'Admin User'
      new_admin_session_path
    else
      throw 'Unknown friendly_user_type_name specified'
    end
  end

  # Returns the path / URL for a password reset of the specified user type.
  def get_new_password_path_for_user_type(friendly_user_type_name)
    case friendly_user_type_name
    when 'External User'
      new_user_password_path
    when 'Internal User'
      new_agency_user_password_path
    when 'Admin User'
      new_admin_password_path
    else
      throw 'Unknown friendly_user_type_name specified'
    end
  end

  # Returns the path / URL for an account unlock of the specified user type.
  def get_unlock_path_for_user_type(friendly_user_type_name)
    case friendly_user_type_name
    when 'External User'
      new_user_unlock_path
    when 'Internal User'
      new_agency_user_unlock_path
    when 'Admin User'
      new_admin_unlock_path
    else
      throw 'Unknown friendly_user_type_name specified'
    end
  end
end

World(UserHelper)
