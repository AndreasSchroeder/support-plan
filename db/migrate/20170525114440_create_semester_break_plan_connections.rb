class CreateSemesterBreakPlanConnections < ActiveRecord::Migration[5.0]
  def change
    create_table :semester_break_plan_connections do |t|
      t.references :user, foreign_key: true
      t.references :day_slot, foreign_key: true
      t.integer :availability

      t.timestamps
    end
  end
end
