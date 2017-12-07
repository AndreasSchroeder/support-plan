require 'day_week'
class SemesterBreakPlan < ApplicationRecord
  has_many :day_slots, -> { order(:start) }
  accepts_nested_attributes_for :day_slots


  def solve type
    solution = []
    case type
    when 0

    when 1
      solution = solve_valid
    when 2
      solution = solve_good
    end
    self.update(solution: "#{solution}")

  end

  def solve_valid
    weeks = DayWeek.generate_weeks(self.day_slots.all)

    weeks.each do |week|
      users = User.users_of_break_plan(self)
      best = week.best_for_users(users, 1)
      sorted_users = self.sort_user_by_av(users, 1)
      p "Best is: #{best}"
    end

    return ["currently empty valid"]
  end

  def solve_good
    return ["currently empty good"]
  end

  def get_users
    update_users
    users = []
    self.day_slots.each do |slot|
      slot.semester_break_plan_connections.each do |con|
        users << con.user
        users.uniq!
      end
    end
    users

  end

  def update_users
    users = User.all
    users.each do |user|
      if has_no_connections user
        if user.planable || user.office
          self.day_slots.each do |slot|
            slot.semester_break_plan_connections.create(user: user)
          end
        end
      else
        if !user.planable && !user.office
          clean_plan user
        end
      end
  	end

  end

  # test if all days are given (holidays can be removed)
  def update_days(users)
    days_between = DaySlot.days_between self.start, self.end
    days_plan = self.day_slots.map {|day| day.start}
    days_new = days_between - days_plan
    if days_new.any?
      days_new.each do |day|
        slot = self.day_slots.create(start: day)
        users.each do |user|
          slot.semester_break_plan_connections.create(user: user)
        end
      end
    end
  end

  private

  def has_no_connections user
    found = false
    self.day_slots.each do |slot|
      slot.semester_break_plan_connections.each do |con|
        if user == con.user
          found = true
        end
      end
    end
    return !found
  end

  def clean_plan user
    all_empty = true
    self.day_slots.each do |slot|
      slot.semester_break_plan_connections.each do |con|
        if user == con.user
          if !(con.availability == 0 || con.availability == nil)
            all_empty = false
          end
        end
      end
    end
    to_delete = []
    if all_empty
      self.day_slots.each do |slot|
        slot.semester_break_plan_connections.each do |con|
          if user == con.user
            if (con.availability == 0 || con.availability == nil)
              to_delete << con
            end
          end
        end
      end
    end
    to_delete.each do |del|
      del.to_delete
    end
  end

  def sort_user_by_av users, av
    self.day_slots.each do |slot|

    end
  end


end
