# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require_relative '../features/support/data_creation.rb'

def output_created_registration(registration)
  puts "Registration created: #{registration['regIdentifier']}, #{registration['tier']}, #{registration['companyName']}, #{registration['contactEmail']}, #{registration['metaData']['status']}"
end

unless Rails.env.production?
  unless Admin.find_by_email('admin@waste-exemplar.gov.uk')
    admin = Admin.new(:email => 'admin@waste-exemplar.gov.uk', :password => 'Secret123')
    admin.save!
  end

  unless Admin.find_by_email('finance@waste-exemplar.gov.uk')
    admin = Admin.new(:email => 'finance@waste-exemplar.gov.uk', :password => 'Secret123')
    admin.add_role :Role_financeSuper, Admin
    admin.save!
  end

  unless Admin.find_by_email('admin1@waste-exemplar.gov.uk')
    admin = Admin.new(:email => 'admin1@waste-exemplar.gov.uk', :password => 'MyS3cr3t!')
    admin.save!
  end

  unless Admin.find_by_email('admin2@waste-exemplar.gov.uk')
    admin = Admin.new(:email => 'admin2@waste-exemplar.gov.uk', :password => 'MyS3cr3t!')
    admin.save!
  end

  unless Admin.find_by_email('gmueller@caci.co.uk')
    admin = Admin.new(:email => 'gmueller@caci.co.uk', :password => 'MyS3cr3t!')
    admin.save!
  end

  AgencyUser.find_or_create_by email: 'agencyuser@nccc.gov.uk', password: 'Secret123'

  AgencyUser.find_or_create_by email: 'nccc1@waste-exemplar.gov.uk', password: 'Secret123'

  AgencyUser.find_or_create_by email: 'nccc2@waste-exemplar.gov.uk', password: 'Secret123'

  # Adds a agency user associated with the finance basic role
  agencyUser = AgencyUser.find_or_create_by email: 'financebasic1@waste-exemplar.gov.uk', password: 'Secret123'
  agencyUser.add_role :Role_financeBasic, AgencyUser

  agencyUser = AgencyUser.find_or_create_by email: 'financebasic2@waste-exemplar.gov.uk', password: 'Secret123'
  agencyUser.add_role :Role_financeBasic, AgencyUser

  agencyUser = AgencyUser.find_or_create_by email: 'financeadmin1@waste-exemplar.gov.uk', password: 'Secret123'
  agencyUser.add_role :Role_financeAdmin, AgencyUser

  agencyUser = AgencyUser.find_or_create_by email: 'financeadmin2@waste-exemplar.gov.uk', password: 'Secret123'
  agencyUser.add_role :Role_financeAdmin, AgencyUser

  agencyUser = AgencyUser.find_or_create_by email: 'agencyrefundpayment1@waste-exemplar.gov.uk', password: 'Secret123'
  agencyUser.add_role :Role_agencyRefundPayment, AgencyUser

  agencyUser = AgencyUser.find_or_create_by email: 'agencyrefundpayment2@waste-exemplar.gov.uk', password: 'Secret123'
  agencyUser.add_role :Role_agencyRefundPayment, AgencyUser

end  #unless Rails.env.production?

if (Rails.env.eql? 'development') || (Rails.env.eql? 'sandbox')
  output_created_registration(create_complete_lower_tier_reg('Charity_LT_online_complete'))
  output_created_registration(create_complete_lower_tier_reg('LTD_LT_online_complete'))
  output_created_registration(create_complete_lower_tier_reg('PB_LT_online_complete'))
  output_created_registration(create_complete_lower_tier_reg('PT_LT_online_complete'))
  output_created_registration(create_complete_lower_tier_reg('ST_LT_online_complete'))
  output_created_registration(create_complete_lower_tier_reg('WA_LT_online_complete'))

  output_created_registration(create_complete_upper_tier_reg('LTD_UT_online_complete', 'Bank Transfer', 5))
  output_created_registration(create_complete_upper_tier_reg('PB_UT_online_complete', 'Bank Transfer', 0))
  output_created_registration(create_complete_upper_tier_reg('PT_UT_online_complete', 'World Pay', 0))
  output_created_registration(create_complete_upper_tier_reg('ST_UT_online_complete', 'World Pay', 4))
  
  RestClient.post "#{Rails.configuration.waste_exemplar_services_admin_url}/tasks/ir-repopulate", {}
end
