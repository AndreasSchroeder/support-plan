class RemoveFixedSolutionToSemesterPlan < ActiveRecord::Migration[5.0]
  def change
    remove_column :semester_plans, :fixed_solution, :string
  end
end
