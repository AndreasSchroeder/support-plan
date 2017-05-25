class TimeSlot < ApplicationRecord
  has_many :semester_plan_connections
  belongs_to :semester_plan
end
