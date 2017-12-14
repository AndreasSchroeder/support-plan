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
    init_av = 1
    best = nil
    best_sol = []
    # get users
    users = User.users_of_break_plan(self)
    i = 0
    while i < 30
      #initialize iteration

      sol = []
      # variables for controlling flow
      filled = false
      error = false

      # type set to 3 -> best results
      type = 3
      rando = false
      if type == 3
        rando = true
      end

      #sort the users by amount of shifts with availability 1
      priority = self.sort_user_by_av(users, 1)

      # calculates shifts for each user by amount of hours
      shifts_user = User.supporter_amount_of_shifts self.day_slots.size, users

      # saves all days.
      # is needed for finding chains of availabilty
      i_week = DayWeek.new(self.day_slots.order(:start).all)

      # helps to resize shifts per user each once
      i_users = users.map{|u| u.id}
      # variable for controlling availability or end
      j = 0
      while !filled && !error
        # sorted list of chains by number of following days with same user and availability
        best = i_week.best_for_users(users, init_av)
        user = nil

        # copy priority for avoiding sideeffects
        priority_dup = priority.dup

        # if type is 3, than shuffle with each step
        if rando
          type = [0,1,2].shuffle.first
        end

        # switch on type
        case type

        # take long chains
        when 0
          selected = priority_dup.sort_by{|u| u[:av].to_i}.first(3).shuffle.first
          while shifts_user.detect{|sh| sh[:user] == selected[:user]}[:shifts] == 0
            priority_dup.delete selected
            selected = priority_dup.sort_by{|u| u[:av].to_i}.first(3).shuffle.first

          end
          user = selected[:user]

        # take short chains
        when 1
          selected = priority_dup.sort_by{|u| u[:av].to_i * -1}.first(3).shuffle.first
          while shifts_user.detect{|sh| sh[:user] == selected[:user]}[:shifts] == 0
            priority_dup.delete selected
            selected = priority_dup.sort_by{|u| u[:av].to_i}.first(3).shuffle.first

          end
          user = selected[:user]

        # take randomw
        when 2
          user = priority.shuffle.first[:user]
        end

        # find all chains of user
        chains = best.detect{|u| u[:user] == user}[:days]

        # find best chain
        best_chain = chains.first
        if best_chain.any?
          shifts = shifts_user.detect{|u| u[:user] == user}[:shifts]
          if shifts < best_chain.size
            if shifts == 0
              best_chain = best_chain.first(shifts)
            else
              start = rand(best_chain.size - shifts - 1)
              best_chain = best_chain[start..shifts - 1]
            end
          end
          best_chain.to_a.each do |s|
            sol << {slot: s, user: User.find(user).id, type: type, av: SemesterBreakPlanConnection.find_plan_by_ids(user, s).availability.to_f}
            j = 0
          end
          i_week.remove_days best_chain
          av = priority.detect{|u| u[:user] == user}[:av]
          priority.detect{|u| u[:user] == user}[:av] -= [av, best_chain.size].min
          shifts_user.detect{|u| u[:user] == user}[:shifts] -= best_chain.size
          priority.delete_if{|d| d[:av] == 0}


          #if SemesterPlanConnection.find_plan_by_ids(u[:user], d).availability <= init_av &&
        end
        if j > users.size * 2
          if i_users.any?
            inc = i_users.shuffle.first
            shifts_user.detect{|su| su[:user] == inc}[:shifts] += 1
            i_users -= [inc]
            j = 0
          end
        end
        if j > users.size * 4
          init_av = 2
        end
        if j > users.size * 8
          error = true
          sol = []
        end
        j += 1

        # fill w
        filled = i_week.days == []
        if filled
          best_sol = best_sol.sort_by{|s| DaySlot.find(s[:slot]).start}
          sol = sol.sort_by{|s| DaySlot.find(s[:slot]).start}
          improve_sol sol
          if get_fitness(sol) > get_fitness(best_sol)
            best_sol = sol
          end
        end
      end

          p "i: #{i}, sol: #{get_fitness(sol)} best: #{get_fitness(best_sol)}"
    i  += 1

    end

    return best_sol.sort_by{|s| s[:slot]}
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

  def get_fitness sol
    if sol == []
      return -1000
    end
    sum = 0.0
    add = 2.0
    last_user = nil
    sol.each do |part|
      if part[:av] == 1
        sum += 3.0
      elsif part[:av] == 2
        sum += 0
      else
        sum -= 10
      end
      if last_user == part[:user]
        sum += add
        add *= 1.1
      else
        if add == 2.0
          sum -= 4.0
        end
        add = 2.0
      end
      last_user = part[:user]
    end
    sum.to_i

  end

  def improve_sol sol
    p find_short_chains 1, sol

  end

  def find_short_chains length, sol
    output = []
    count = 1
    last = {user: nil}
    shifts = []
    shifts << sol.first[:slot]
    sol.each do |part|
      if last[:user] == part[:user]
        shifts << part[:slot]
      else
        if shifts.size == length && last[:user]
          output << {user: last[:user], slots: shifts}
        end
        shifts = []
        shifts << part[:slot]
      end
      last = part
    end
    output
  end

  def get_amount_of_shifts_in_solution user
    shifts = 0
    eval(self.solution).each do |part|
      if part[:user] == user.id
        shifts += 1
      end
    end
    shifts
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
      del.delete
    end
  end

end
