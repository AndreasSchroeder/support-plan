class AddOfficeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :office, :boolean, default: false
  end
end
