class AddPlanableToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :planable, :boolean, default: true
  end
end
