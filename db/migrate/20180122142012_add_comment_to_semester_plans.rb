class AddCommentToSemesterPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_plans, :comment, :text
  end
end
