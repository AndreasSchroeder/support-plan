class AddFieldsToSemesterPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_plans, :solution, :text
  end
end
