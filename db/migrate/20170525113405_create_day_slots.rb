class CreateDaySlots < ActiveRecord::Migration[5.0]
  def change
    create_table :day_slots do |t|
      t.date :start
      t.references :semester_break_plan, foreign_key: true


      t.timestamps
    end
  end
end
