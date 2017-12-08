require 'day_week'
class SemesterBreakPlan < ApplicationRecord
  has_many :day_slots, -> { order(:start) }
  accepts_nested_attributes_for :day_slots

  # redirect solving to correct method
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

  # solves plan with a valid solution
  def solve_valid
    # generates array of weeks for all days
    weeks = DayWeek.generate_weeks(self.day_slots.all)

    # get users
    users = User.users_of_break_plan(self)

    #gives for each week the user with the most following availability in a week
    weeks.each do |week|
      best = week.best_for_users(users, 1)
      sorted_users = self.sort_user_by_av(users, 1)
      p "Best is: #{best}"
    end
    availabiltys_users = sort_user_by_av users, 1
    p "av: #{ availabiltys_users }"
    shifts_user = User.supporter_amount_of_shifts self.day_slots.size, users
    p "shifts: #{shifts_user}"
    return ["currently empty valid"]
  end

  # solves the plan with good solution
  def solve_good
    return ["currently empty good"]
  end

  # a list of all users wich have connections in the plan
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

  # updates users
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

  def sort_user_by_av users, av
    avs = []
    users.each do |user|
      av_sum = 0
      self.day_slots.each do |slot|
        fav = slot.semester_break_plan_connections.detect{|con| con.user == user}.availability.to_i
        av_sum +=1 if (fav != 0 && fav <= av)
      end
      avs << {user: user.id, av: av_sum}
    end
    avs.sort_by{|user| user[:av]}
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

end
