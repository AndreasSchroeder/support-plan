class AddFixed3SolutionToSemesterPlan < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_plans, :fixed_solution, :text
  end
end
