class AddInactiveToSemesterPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_plans, :inactive, :boolean, default: false
  end
end
