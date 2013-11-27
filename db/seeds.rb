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

if AgencyUser.count == 0
  au = AgencyUser.new(:email => 'nccc1@waste-exemplar.gov.uk', :password => 'secret123')
  au.save!
end

if (!User.find_by_email('joe@company.com'))
  user = User.new(:email => 'joe@company.com', :password => 'secret123')
  user.save!
end

#Loading agency users from file.
data = YAML::load(File.read("db/NCCC-users.txt"))
data.split(" ").each {|e| 
  if !AgencyUser.where(email: e).exists?
    pw = (0...16).map { (65 + SecureRandom.random_number(52)).chr }.join
    au = AgencyUser.new(:email => e, :password => pw)
    au.save!
  end
}
