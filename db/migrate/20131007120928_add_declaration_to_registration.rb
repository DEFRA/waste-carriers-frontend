class AddDeclarationToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :declaration, :string
  end
end
