if ENV['WCRS_FRONTEND_USE_AIRBRAKE'] && !Rails.env.test?

  project_id = ENV['WCRS_FRONTEND_AIRBRAKE_PROJECT_ID'].to_i

  Airbrake.configure do |config|
    config.host = ENV['WCRS_FRONTEND_AIRBRAKE_HOST']
    config.project_id = project_id.zero? ? 1 : project_id
    config.project_key = ENV['WCRS_FRONTEND_AIRBRAKE_PROJECT_KEY']
    config.root_directory = Rails.root
    config.app_version = Rails.configuration.application_version
    config.environment = Rails.env

    config.blacklist_keys = [
      # Catch-all "safety net" regexes.
      /password/i,
      /conviction/i,
      /postcode/i,
      /warden/i,

      # Attributes from the registration.
      :companyName,
      :company_no,
      :title,      # Questionable, but don't think we use this anyway.
      :firstName,
      :lastName,
      :position,   # Questionable, but don't think we use this anyway.
      :phoneNumber,
      :contactEmail,
      :accountEmail,
      # :password,                   # Caught by regex above; shown here only for completeness.
      :accessCode,
      :selectedAddress,
      # :declaredConvictions,        # Caught by regex above; shown here only for completeness.
      :addresses,
      :key_people,
      # :conviction_search_result,   # Caught by regex above; shown here only for completeness.
      # :conviction_sign_offs,       # Caught by regex above; shown here only for completeness.

      # Attributes from a user / agency-user / admin.
      :email,
      # :encrypted_password,         # Caught by regex above; shown here only for completeness.
      :reset_password_token,
      :current_sign_in_ip,
      :last_sign_in_ip,
      :confirmation_token,
      :unconfirmed_email,
      :unlock_token,

      # Attributes from a key person.
      :first_name,
      :last_name,
      :dob_day,
      :dob_month,
      :dob_year,
      :dob,

      # Attributes from meta data.
      :revokedReason,  # Free-text; NCCC could enter PII.

      # Attributes from a conviction search result (if not nested inside a
      # registration).
      :match_result,
      :matching_system,
      :reference,
      :matched_name,

      # Attributes from a payment.
      :mac_code,
      :comment,        # Free-text; NCCC could enter PII.

      # Attributes from an address - almost all fields!
      :registration_selectedAddress,
      :uprn,
      :houseNumber,
      :addressLine1,
      :addressLine2,
      :addressLine3,
      :addressLine4,
      :townCity,
      # :postcode,            # Caught by regex above; shown here only for completeness.
      :dependentLocality,
      :dependentThoroughfare,
      :localAuthorityUpdateDate,
      :royalMailUpdateDate,
      :easting,
      :northing,
      :firstName,
      :lastName,
      :location,

      # Form fields that are worthy of listing.
      :accountEmail_confirmation,
      # :password_confirmation,     # Caught by regex above; shown here only for completeness.

      # Things stored in the session.
      :userEmail,
      :ga_convictions,  # Flag sent to Google Analytics

      # Other things we'll filter beacuse we're super-diligent.
      :_csrf_token,
      :session_id,
      :authenticity_token
    ]
  end

  # Don't log bogus exceptions caused by Passenger:
  # https://github.com/airbrake/airbrake/issues/490
  Airbrake.add_filter do |notice|
    nomethoderror = proc do |error|
      error[:backtrace].empty? &&
        error[:type] == 'NoMethodError' &&
        error[:message] =~ %r{undefined method `call'}
    end

    notice.ignore! if notice[:errors].any?(&nomethoderror)
  end

  # Filter-out logged-in customer's email address.  This cannot be done using the
  # blacklist_keys above presently, hence a separate filter here.
  Airbrake.add_filter do |notice|
    if notice && notice[:context] && notice[:context][:user] && notice[:context][:user][:email]
      notice[:context][:user][:email] = '[Filtered]'
    end
  end
end
