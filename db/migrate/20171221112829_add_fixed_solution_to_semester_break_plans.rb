class AddFixedSolutionToSemesterBreakPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_break_plans, :fixed_solution, :text
  end
end
