class DaySlot < ApplicationRecord
  has_many :semester_break_plan_connections
  belongs_to :semester_break_plan
end
