class SemesterPlan < ApplicationRecord
  include ApplicationHelper
  has_many :time_slots



  def get_fitness_of_solution
    solution = eval(self.solution)
    if solution == nil
      return {fitness: 0, unfitness: 0}
    end

    fitness = solution.inject(0){|sum, v|
      case get_av v, false
      when "av1"
        sum + 3
      when "av2"
        sum + 1
      when "av3"
        sum + -5
      else
        sum + 0
      end
    }

    days = [[], [], [], [], []]
    solution.each do |s|
      days[s[:index].to_i/5].push s
    end
    fitness += days.inject(0){|sum, day|
      last = nil
      sum + day.each_with_index.inject(0) do|sum2, (shift, index)|
        if index != 0
          p "Shift: #{shift}"
          p "Last : #{last}"
          if shift[:user] == last[:user]
            if sum2 == 0
              sum2 += 2
            else
              sum2 += 1
            end
          end
        end
        last = shift
        sum2
      end
    }
    unfitness = solution.inject(0){|sum, v|
      case get_av v, false
      when "av3"
        sum + 1
      else
        sum + 0
      end
    }
    return {fitness: fitness, unfitness: unfitness}
  end

  def get_amount_of_shifts_in_solution user
    solution = eval(self.solution)

    a = solution.inject(0){|sum, x|
      if x[:user].to_i == user.id
        sum + 1
      else
        sum + 0
      end
    }
    b = solution.inject(0){|sum, x|
      if x[:co].to_i == user.id
        sum + 1
      else
        sum + 0
      end
    }

    return "#{a}/#{b}"
  end

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
