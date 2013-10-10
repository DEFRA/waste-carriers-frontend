class BusinessType < ActiveRecord::Migration
  def change
    change_table :registrations do |t|
      t.rename :organisationType, :businessType
    end
  end
end
