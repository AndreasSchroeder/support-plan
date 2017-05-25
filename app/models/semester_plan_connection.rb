class SemesterPlanConnection < ApplicationRecord
  belongs_to :user
  belongs_to :time_slot

  def self.are_build?(user, plan)
    return SemesterPlanConnection.find_by(user_id: user.id, time_slot_id: plan.time_slots.first.id) != nil
  end

  def self.find_it(user, slot)
    return SemesterPlanConnection.find_by(user_id: user.id, time_slot_id: slot.id)

  end
    def self.find_it_id(user, slot)
    return SemesterPlanConnection.find_by(user_id: user, time_slot_id: slot)

  end
end
