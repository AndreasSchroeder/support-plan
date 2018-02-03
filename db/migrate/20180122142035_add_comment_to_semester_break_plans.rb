class AddCommentToSemesterBreakPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_break_plans, :comment, :text
  end
end
