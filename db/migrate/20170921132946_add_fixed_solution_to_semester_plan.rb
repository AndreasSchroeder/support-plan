class AddFixedSolutionToSemesterPlan < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_plans, :fixed_solution, :string
  end
end
