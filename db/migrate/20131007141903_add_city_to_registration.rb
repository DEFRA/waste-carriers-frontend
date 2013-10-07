class AddCityToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :city, :string
  end
end
