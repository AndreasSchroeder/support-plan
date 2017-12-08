class SemesterBreakPlanConnection < ApplicationRecord
  belongs_to :user
  belongs_to :day_slot

  def self.find_plan_by_ids user, slot
    SemesterBreakPlanConnection.find_by(user: user, day_slot: slot)
  end
end
