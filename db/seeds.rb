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
  au = AgencyUser.new(:email => 'joe.bloggs@waste-exemplar.gov.uk', :password => 'secret123')
  au.save!
end

