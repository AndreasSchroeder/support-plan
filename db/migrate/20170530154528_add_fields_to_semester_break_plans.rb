class AddFieldsToSemesterBreakPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_break_plans, :solution, :text
  end
end
