class AddAddress1ToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :address1, :string
  end
end
