class CreateSemesterBreakPlans < ActiveRecord::Migration[5.0]
  def change
    create_table :semester_break_plans do |t|
      t.datetime :start
      t.datetime :end
      t.string :name

      t.timestamps
    end
  end
end
