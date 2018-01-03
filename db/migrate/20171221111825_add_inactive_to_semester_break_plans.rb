class AddInactiveToSemesterBreakPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_break_plans, :inactive, :boolean, default: false
  end
end
