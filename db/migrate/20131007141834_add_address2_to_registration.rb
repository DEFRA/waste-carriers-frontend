class AddAddress2ToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :address2, :string
  end
end
