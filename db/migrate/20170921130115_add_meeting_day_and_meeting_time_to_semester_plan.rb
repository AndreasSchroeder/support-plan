class AddMeetingDayAndMeetingTimeToSemesterPlan < ActiveRecord::Migration[5.0]
  def change
    add_column :semester_plans, :meeting_day, :string
    add_column :semester_plans, :meeting_time, :integer
  end
end
