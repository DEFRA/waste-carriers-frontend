if ENV['WCRS_FRONTEND_USE_AIRBRAKE'] && !Rails.env.test?
  Airbrake.configure do |config|
    config.host = ENV['WCRS_FRONTEND_AIRBRAKE_HOST']
    config.project_id = ENV['WCRS_FRONTEND_AIRBRAKE_PROJECT_ID']
    config.project_key = ENV['WCRS_FRONTEND_AIRBRAKE_PROJECT_KEY']
    config.root_directory = Rails.root

    config.blacklist_keys = [
      # Catch-all "safety net" regexes.
      /password/i,
      /conviction/i,
      /postcode/i,

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
      :# postcode,            # Caught by regex above; shown here only for completeness.
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
end
