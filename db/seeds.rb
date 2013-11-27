# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first) 

# TODO FIXME - Remove for production!!!

if Admin.count == 0
  admin = Admin.new(:email => 'admin@waste-exemplar.gov.uk', :password => 'secret123')
  admin.save!
end

# TODO - Remove these after pen test
if !Admin.find_by_email('admin1@waste-exemplar.gov.uk')
  admin = Admin.new(:email => 'admin1@waste-exemplar.gov.uk', :password => 'MyS3c3t!')
  admin.save!
end
if !Admin.find_by_email('admin2@waste-exemplar.gov.uk')
  admin = Admin.new(:email => 'admin2@waste-exemplar.gov.uk', :password => 'MyS3cr3t!')
  admin.save!
end
if !Admin.find_by_email('michal.sobczak@irmplc.com')
  admin = Admin.new(:email => 'michal.sobczak@irmplc.com', :password => 'MyS3cr3t!')
  admin.save!
end

if !AgencyUser.find_by_email('nccc1@waste-exemplar.gov.uk')
  au = AgencyUser.new(:email => 'nccc1@waste-exemplar.gov.uk', :password => 'secret123')
  au.save!
end

if !AgencyUser.find_by_email('nccc2@waste-exemplar.gov.uk')
  au = AgencyUser.new(:email => 'nccc2@waste-exemplar.gov.uk', :password => 'secret123')
  au.save!
end

if (!User.find_by_email('joe@company.com'))
  user = User.new(:email => 'joe@company.com', :password => 'secret123')
  user.save!
end

#Loading agency users from file.
#data = YAML::load(File.read("db/NCCC-users.txt"))
#data.split(" ").each {|e| 
#  if AgencyUser.find_by_email(e)
#  	puts "AgencyUser with email " + e + " already exists. Not added again."
#  else
#    pw = (0...16).map { (65 + SecureRandom.random_number(52)).chr }.join
#    au = AgencyUser.new(:email => e, :password => pw)
#    if !au.save
#      puts "AgencyUser with email " + e + " could not be saved."
#    end
#  end
#}
