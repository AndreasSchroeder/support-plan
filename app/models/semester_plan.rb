class SemesterPlan < ApplicationRecord
  include ApplicationHelper
  has_many :time_slots


  def has_entrys(user)
    yes = true
    found = false
    self.time_slots.each do |slot|
      slot.semester_plan_connections.each do | con|
        if con.user == user
          found = true
          if con.availability == 0 || con.availability == nil

            yes = false

          end
        end
      end
    end
    if !found
      return false
    end
    return yes
  end

  def get_fitness_of_solution (solution)

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
      days[s[:index].to_i/4].push s
    end
    fitness += days.inject(0){|sum, day|
      last = nil
      sum + day.each_with_index.inject(0) do|sum2, (shift, index)|
        if last
          if shift[:user] == last[:user]
            if shift[:index]%4 != 0
              sum2 += 2
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
      when "av2", "av1"
        sum + 0
      else
        sum + 10
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
    users = User.where(planable: true, inactive: false)
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

  def get_slots_of_user_av1 solution, u0, u1, s0, s1
    slots = []
    user0 = User.find(u0)
    user1 = User.find(u1)
    slot0 = s0.to_i
    slot1 = s1.to_i
    self.time_slots.each do |slot|
      found = solution.detect{|x| x[:slot].to_i == slot.id.to_i}
      if found
        if  found[:user].to_i == u0.to_i && SemesterPlanConnection.find_it_id(user1.id, slot.id).availability == 1 && SemesterPlanConnection.find_it_id(user0.id, slot1).availability == 1 && slot.id.to_i != slot1.to_i && slot.id.to_i != slot0.to_i
          slots << slot
        end
      end
    end
    slots
  end

  def ready_to_plan?
    self.time_slots.each do |slot|
      slot.semester_plan_connections.each do |con|
        if con.availability == 0 || con.availability == nil
          return false
        end
      end
    end
    return true
  end

  def best_meeting_dates
    meetings =  []
    self.time_slots.each do |slot|
      score = slot.semester_plan_connections.inject(0){|sum, c |
        value = 0
        if c.availability == 1
          value = 1
        end
        sum + value
      }
      meetings << {score: score, slot: slot}
    end
    meetings.sort_by do |item|
      item[:score] * -1
    end
  end

  def compare_solutions sol1, sol2
    fit1 = self.get_fitness_of_solution sol1
    fit2 = self.get_fitness_of_solution sol2
    if fit1 && fit2
      if fit1[:fitness] > fit2[:fitness]
        return sol1
      elsif fit1[:fitness] < fit2[:fitness]
        return sol2
      elsif fit1[:unfitness] <= fit2[:unfitness]
        return sol1
      else
        return sol2
      end
    end

  end


end
