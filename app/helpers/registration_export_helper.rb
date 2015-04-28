# Provides methods used when exporting Registration data to CSV, or a table
# embedded in a web page.  Each method provides a data array; formatting should
# be handled by the caller.
module RegistrationExportHelper
  include ApplicationHelper
  
  def regexport_get_headers(style)
    case style
    when 'full'
      get_headers_full
    else
      fail 'Unrecognised style requested'
    end
  end
  
  def regexport_get_registration_data(style, registration)
    case style
    when 'full'
      get_registration_data_full(registration)
    else
      fail 'Unrecognised style requested'
    end
  end
  
  def regexport_get_person_data(style, registration, person)
    case style
    when 'full'
      get_keyperson_data_full(registration, person)
    else
      fail 'Unrecognised style requested'
    end
  end
  
  def pad_array_to_match_length(template, target)
    length_diff = template.length - target.length
    if length_diff > 0
      target.concat(Array.new(length_diff, ''))
    else
      target
    end
  end
  
  private
  def bool_to_string(value)
    value ? 'Yes' : 'No'
  end
  
  private
  def get_headers_full()
    [
      I18n.t('reports.fields.reg_identifier'),
      I18n.t('reports.fields.company_name'),
      I18n.t('reports.fields.house_number'),
      I18n.t('reports.fields.street_line_1'),
      I18n.t('reports.fields.street_line_2'),
      I18n.t('reports.fields.street_line_3'),
      I18n.t('reports.fields.street_line_4'),
      I18n.t('reports.fields.town_city'),
      I18n.t('reports.fields.postcode'),
      I18n.t('reports.fields.first_name'),
      I18n.t('reports.fields.last_name'),
      I18n.t('reports.fields.position'),
      I18n.t('reports.fields.phone_number'),
      I18n.t('reports.fields.contact_email'),
      I18n.t('reports.fields.account_email'),
      I18n.t('reports.fields.business_type'),
      I18n.t('reports.fields.other_businesses'),
      I18n.t('reports.fields.is_main_service'),
      I18n.t('reports.fields.construction_waste'),
      I18n.t('reports.fields.only_amf'),
      I18n.t('reports.fields.tier'),
      I18n.t('reports.fields.registration_type'),
      I18n.t('reports.fields.company_no'),
      I18n.t('reports.fields.date_registered'),
      I18n.t('reports.fields.date_activated'),
      I18n.t('reports.fields.status'),
      I18n.t('reports.fields.pending_payment'),
      I18n.t('reports.fields.pending_convictions'),
      I18n.t('reports.fields.route'),
      I18n.t('reports.fields.access_code'),
      I18n.t('reports.fields.expires_on'),
      I18n.t('reports.fields.company_match_result'),
      I18n.t('reports.fields.company_matched_name'),
      I18n.t('reports.fields.company_match_reference'),
      I18n.t('reports.fields.declared_convictions'),
      I18n.t('reports.fields.key_first_name'),
      I18n.t('reports.fields.key_last_name'),
      I18n.t('reports.fields.key_dob'),
      I18n.t('reports.fields.key_position'),
      I18n.t('reports.fields.key_person_type'),
      I18n.t('reports.fields.key_match_result'),
      I18n.t('reports.fields.key_matched_name'),
      I18n.t('reports.fields.key_match_reference'),
      I18n.t('reports.fields.key_confirmed')
    ]
  end
  
  private
  def get_registration_data_full(registration)
    isUpper = registration.upper?
    [
      registration.regIdentifier,
      registration.companyName,
      registration.houseNumber,
      registration.streetLine1,
      registration.streetLine2,
      registration.streetLine3,
      registration.streetLine4,
      registration.townCity,
      registration.postcode,
      registration.firstName,
      registration.lastName,
      registration.position,
      registration.phoneNumber,
      registration.contactEmail,
      registration.accountEmail,
      registration.businessType,
      registration.otherBusinesses,
      registration.isMainService,
      registration.constructionWaste,
      registration.onlyAMF,
      registration.tier,
      isUpper ? registration.registrationType : '',
      isUpper ? registration.company_no : '',
      format_as_date_only(registration.metaData.first.dateRegistered),
      format_as_date_only(registration.metaData.first.dateActivated, blank_if_epoch: true),
      registration.metaData.first.status,
      isUpper ? bool_to_string(!registration.paid_in_full?) : '',
      isUpper ? bool_to_string(registration.is_awaiting_conviction_confirmation?) : '',
      registration.metaData.first.route,
      registration.accessCode,
      format_as_date_only(registration.expires_on, blank_if_epoch: true),
      isUpper ? registration.conviction_search_result.first.match_result : '',
      isUpper ? registration.conviction_search_result.first.matched_name : '',
      isUpper ? registration.conviction_search_result.first.get_formatted_reference() : '',
      isUpper ? registration.declaredConvictions : ''
    ]
  end
  
  private
  def get_keyperson_data_full(registration, person)
    [
      person.first_name,
      person.last_name,
      format_as_date_only(person.dob),
      person.position,
      person.person_type,
      person.conviction_search_result.first.match_result,
      person.conviction_search_result.first.matched_name,
      person.conviction_search_result.first.get_formatted_reference(),
      person.conviction_search_result.first.confirmed
    ]
  end
end