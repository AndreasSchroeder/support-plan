class AddFreeToSemesterPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_plans, :free, :boolean, default: false
  end
end
