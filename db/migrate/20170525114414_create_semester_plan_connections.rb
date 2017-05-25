class CreateSemesterPlanConnections < ActiveRecord::Migration[5.0]
  def change
    create_table :semester_plan_connections do |t|
      t.references :user, foreign_key: true
      t.references :time_slot, foreign_key: true
      t.integer :availability

      t.timestamps
    end
  end
end
