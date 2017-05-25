class CreateTimeSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :time_slots do |t|
      t.integer :start
      t.integer :end
      t.string :day
      t.references :semester_plan, foreign_key: true

      t.timestamps
    end
  end
end
