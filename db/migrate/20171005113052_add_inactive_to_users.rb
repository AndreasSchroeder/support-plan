class AddInactiveToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :inactive, :boolean, default: false
  end
end
