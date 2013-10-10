# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131010114503) do

  create_table "registrations", :force => true do |t|
    t.string   "registerAs"
    t.string   "businessType"
    t.string   "companyName"
    t.string   "individualsType"
    t.string   "publicBodyType"
    t.string   "title"
    t.string   "firstName"
    t.string   "lastName"
    t.string   "phoneNumber"
    t.string   "email"
    t.string   "houseNumber"
    t.string   "postcode"
    t.string   "uprn"
    t.string   "address"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "declaration"
    t.string   "publicBodyTypeOther"
    t.string   "streetLine1"
    t.string   "streetLine2"
    t.string   "townCity"
  end

end
