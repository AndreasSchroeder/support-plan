class SemesterPlan < ApplicationRecord
  has_many :time_slots


  def get_slot_priority
    slots = self.time_slots

    priority = []
    slots.each do |s|
      priority << {slot: s.id, priority: s.get_priority, index: s.get_type}
    end
    priority.sort_by! {|item|
      item[:priority] * -1
    }
    priority
  end

  def self.kill_user_in_slot_priority user, slots
    slots.each do |slot|
      slot[:priority] -= SemesterPlan.slot_user_value(slot[:slot], user)
      if slot[:priority] < 0
        slot[:priority] = 0
      end
    end
    slots
  end

  def self.kill_slot_in_user_priority slot, users
    users.each do |user|
      user[:priority] -= SemesterPlan.slot_user_value slot, user[:user]
      if user[:priority] < 0
        user[:priority] =0
      end
    end
    users
  end

  def self.slot_user_value slot, user
    value = 0
    TimeSlot.find(slot).semester_plan_connections.each do |c|
      if c.user_id == user
        value =  c.availability
      end
    end
    value
  end

  def get_user_priority
    users = User.where(planable: true)
    slots = self.time_slots

    priority = []
    users.each do |u|
      priority << {user: u.id, priority: 0}
    end
    slots.each do |s|
      s.semester_plan_connections.each do |c|
        priority.each do |p|
          if p[:user] == c.user.id
            p[:priority] += c.availability
          end
        end
      end
    end
    priority.sort_by! {|item|
      item[:priority] * -1
    }
    priority
  end


end
