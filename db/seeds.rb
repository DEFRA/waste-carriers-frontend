# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# TODO - REMOVE AFTER COMPLETION OF PENETRATION SECURITY TESTS
# ATTENTION - TEST ACCOUNTS TO BE REMOVED !!!

#unless Rails.env.production?
unless Admin.find_by_email('admin@waste-exemplar.gov.uk')
  admin = Admin.new(:email => 'admin@waste-exemplar.gov.uk', :password => 'secret123')
  admin.save!
end

unless Admin.find_by_email('finance@waste-exemplar.gov.uk')
  admin = Admin.new(:email => 'finance@waste-exemplar.gov.uk', :password => 'secret123')
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

unless Admin.find_by_email('rob.mcelvanney@irmplc.com')
  admin = Admin.new(:email => 'rob.mcelvanney@irmplc.com', :password => 'MyS3cr3t!')
  admin.save!
end

unless Admin.find_by_email('gmueller@caci.co.uk')
  admin = Admin.new(:email => 'gmueller@caci.co.uk', :password => 'MyS3cr3t!')
  admin.save!
end

AgencyUser.find_or_create_by email: 'agencyuser@nccc.gov.uk', password: 'secret123'

AgencyUser.find_or_create_by email: 'nccc1@waste-exemplar.gov.uk', password: 'secret123'

AgencyUser.find_or_create_by email: 'nccc2@waste-exemplar.gov.uk', password: 'secret123'

# Adds a agency user associated with the finance basic role
agencyUser = AgencyUser.find_or_create_by email: 'financebasic1@waste-exemplar.gov.uk', password: 'secret123'
agencyUser.add_role :Role_financeBasic, AgencyUser

agencyUser = AgencyUser.find_or_create_by email: 'financebasic2@waste-exemplar.gov.uk', password: 'secret123'
agencyUser.add_role :Role_financeBasic, AgencyUser

agencyUser = AgencyUser.find_or_create_by email: 'financeadmin1@waste-exemplar.gov.uk', password: 'secret123'
agencyUser.add_role :Role_financeAdmin, AgencyUser

agencyUser = AgencyUser.find_or_create_by email: 'financeadmin2@waste-exemplar.gov.uk', password: 'secret123'
agencyUser.add_role :Role_financeAdmin, AgencyUser

agencyUser = AgencyUser.find_or_create_by email: 'agencyrefund1@waste-exemplar.gov.uk', password: 'secret123'
agencyUser.add_role :Role_ncccRefund, AgencyUser

agencyUser = AgencyUser.find_or_create_by email: 'agencyrefund2@waste-exemplar.gov.uk', password: 'secret123'
agencyUser.add_role :Role_ncccRefund, AgencyUser

agencyUser = AgencyUser.find_or_create_by email: 'agencypayment1@waste-exemplar.gov.uk', password: 'secret123'
agencyUser.add_role :Role_ncccPayment, AgencyUser

agencyUser = AgencyUser.find_or_create_by email: 'agencypayment2@waste-exemplar.gov.uk', password: 'secret123'
agencyUser.add_role :Role_ncccPayment, AgencyUser

#end  #unless Rails.env.production?

#Environment Agency Administrators
if !Admin.find_by_email('jamie.dempster@environment-agency.gov.uk')
  admin = Admin.new(:email => 'jamie.dempster@environment-agency.gov.uk', :password => AgencyUser.random_password)
  admin.save!
end
if !Admin.find_by_email('beverley.patterson@environment-agency.gov.uk')
  admin = Admin.new(:email => 'beverley.patterson@environment-agency.gov.uk', :password => AgencyUser.random_password)
  admin.save!
end


#TODO Remove after testing
#if !Admin.find_by_email('gmueller@caci.co.uk')
#  admin = Admin.new(:email => 'gmueller@caci.co.uk', :password => AgencyUser.random_password)
#  admin.save!
#end

#if !AgencyUser.find_by_email('gmueller@caci.co.uk')
#  au = AgencyUser.new(:email => 'gmueller@caci.co.uk', :password => AgencyUser.random_password)
#  au.save!
#end

if (Rails.env.eql? 'development') && (ENV["WCRS_REG_SEED"].eql? 'true')

  #load some sample registrations
  data =  YAML::load(File.read("db/lower_tier_registrations.json")) +  YAML::load(File.read("db/upper_tier_registrations.json"))

  data.each do |reg|
    r = Registration.init(reg)
    if r && r.commit
      puts "waste carrier #{r.companyName} registered!"
      r.metaData.first.update(status: 'ACTIVE')
      r.save!

    else puts "Registration failed for #{reg['companyName']}"
    end

  end

  #load some users
  data =  YAML::load(File.read("db/users.json"))
  data.each do |usr|
    u = User.new(usr)
    puts "user #{u.email} created" if u.save
  end


end  #if



#Loading agency users from file.
data = YAML::load(File.read("db/NCCC-Users.txt"))
data.split(" ").each {|e|
  if AgencyUser.find_by_email(e)
    puts "AgencyUser with email " + e + " already exists. Not added again."
  else
    pw = AgencyUser.random_password
    au = AgencyUser.new(:email => e, :password => pw)
    if !au.save
      puts "AgencyUser with email " + e + " could not be saved."
    end
  end
}
