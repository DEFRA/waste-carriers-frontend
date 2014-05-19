class PublicBodyOther < ActiveRecord::Migration
  def change
    change_table :registrations do |t|
      t.rename :publicBodyOther, :publicBodyTypeOther
    end
  end
end
