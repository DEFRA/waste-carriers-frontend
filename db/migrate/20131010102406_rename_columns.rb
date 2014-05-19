class RenameColumns < ActiveRecord::Migration

  def change
    change_table :registrations do |t|
      t.rename :emailAddress, :email
      t.rename :organisationName, :companyName
      t.rename :address1, :streetLine1
      t.rename :address2, :streetLine2
      t.rename :city, :townCity
      t.remove :companyRegistrationNumber
    end
  end

end
