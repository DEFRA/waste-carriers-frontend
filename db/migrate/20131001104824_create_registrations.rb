class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.string :registerAs
      t.string :organisationType
      t.string :organisationName
      t.string :individualsType
      t.string :companyRegistrationNumber
      t.string :publicBodyType
      t.string :title
      t.string :firstName
      t.string :lastName
      t.string :phoneNumber
      t.string :emailAddress
      t.string :houseNumber
      t.string :postcode
      t.string :uprn
      t.string :address

      t.timestamps
    end
  end
end
