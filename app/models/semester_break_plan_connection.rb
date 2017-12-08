class SemesterBreakPlanConnection < ApplicationRecord
  belongs_to :user
  belongs_to :day_slot

  def find_plan_by_ids user, slot
    SemesterBreakPlanConnection.find_by(user.id, slot.id)
  end
end
