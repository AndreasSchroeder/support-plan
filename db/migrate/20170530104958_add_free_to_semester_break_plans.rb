class AddFreeToSemesterBreakPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_break_plans, :free, :boolean, default: false
  end
end
