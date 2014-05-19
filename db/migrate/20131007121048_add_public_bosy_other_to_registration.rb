class AddPublicBosyOtherToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :publicBodyOther, :string
  end
end
