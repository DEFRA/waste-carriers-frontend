Then('I change the business address on my registration and confirm the change') do
  user_registrations_page_click_edit_registration_link
  confirmation_page_click_edit_business_address_link
  business_details_page_change_business_address
  confirmation_page_agree_to_declaration_and_submit
end

Then('my registration shows the new business address') do
  user_registrations_page_click_edit_registration_link
  confirmation_page_check_business_address_has_changed
end

Then('I sign out of my waste carriers account') do
  user_registrations_page_sign_out_user
end
