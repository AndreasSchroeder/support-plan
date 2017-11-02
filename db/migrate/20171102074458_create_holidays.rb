class CreateHolidays < ActiveRecord::Migration[5.0]
  def change
    create_table :holidays do |t|
      t.date :day
      t.string :name

      t.timestamps
    end
  end
end
