class SemesterPlanConnection < ApplicationRecord
  belongs_to :user
  belongs_to :time_slot

  # checks if connection was initialized
  def self.are_build?(user, plan)
    return SemesterPlanConnection.find_by(user_id: user.id, time_slot_id: plan.time_slots.first.id) != nil
  end

  # find connection
  def self.find_it(user, slot)
    return SemesterPlanConnection.find_by(user_id: user.id, time_slot_id: slot.id)

  end

  # find conection
  def self.find_it_id(user, slot)
    return SemesterPlanConnection.find_by(user_id: user, time_slot_id: slot)

  end
end
