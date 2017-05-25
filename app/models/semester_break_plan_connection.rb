class SemesterBreakPlanConnection < ApplicationRecord
  belongs_to :user
  belongs_to :day_slot
end
