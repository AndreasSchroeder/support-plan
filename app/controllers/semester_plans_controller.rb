require 'json'
class SemesterPlansController < ApplicationController

  # action for new plan
  def new
    @plan = SemesterPlan.new
  end

  # action to fill plan with data
  def create
    @plan = SemesterPlan.new(plan_params)
      if @plan.save
        ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"].each do |day|
          start_time = 8
          4.times do
            timeslot = @plan.time_slots.create!(start: start_time, end: start_time + 2, day: day)
            start_time += 2
          end
        end
        flash[:success] = "Erstellen erfolgreich"
        redirect_to semester_plan_path @plan
      else
        flash[:danger] = "Erstellen fehlgeschlagen"
        redirect_to new_semester_plan_path
      end

  end

  def index
  end

  # action for showing a valid solution
  def valid
    @plan = SemesterPlan.find(params[:id])
    @solution = eval(@plan.solution)
  end

  # action for showing a plan. Users are able to fill in Shiftavailibility
  def show
    @plan = SemesterPlan.find(params[:id])
    @users = User.where(planable: true)
    @slots = []
    @options = {0 => "gültige Lösung", 1 => "mehrere gültige Lösungn", 2 => "hinreichend optimale Lösung"}
    @users.each do |user|
      found = !SemesterPlanConnection.are_build?(user, @plan)
      @plan.time_slots.each do |slot|
        type = slot_type slot
        if found
          @slots << SemesterPlanConnection.create(user: user, time_slot: slot, typus: type, availability: 0)
        else
          @slots << SemesterPlanConnection.find_it(user, slot)
        end
      end
    end
  end

  # splits post-actions into rigth actions
  def handle
    # for user input
    if params["connections"]
      connect(params)
       redirect_to action: "show"
    # starts optimization of plan or creats at least valid plan if possible
    elsif params["optimisation"]
      optimize(params)
    # activate plan for user input
    elsif params["free"]
      flash[:success] = "Plan zur Bearbeitung freigegeben"
      SemesterPlan.find(params[:id]).update(free: true)
       redirect_to action: "show"
    end


  end



  private
  # whitelistet parameters
  def plan_params
    params.require(:semester_plan).permit(:start, :end, :name)
  end

  # connects User with timeslot
  def connect(params)
    #p params["connections"]
    params["connections"].each do |key, value|
      value = value.to_i
      if value == 0 || value == 1 || value == 2 || value == 3
        SemesterPlanConnection.find_it_id(key.split(";").first.to_i, key.split(";").last.to_i).update(availability: value.to_i)
        flash[:success] = "Änderungen übernommen."
      else
        flash[:danger] = "Bitte nur folgende Wert eingeben: 0 (leer), 1 (sicher), 2 (nicht so gut), 3 (gar nicht)"

      end
    end
  end

  # switch action to serveral methods
  def optimize(params)
    case params["optimisation"]["kind"]
      when "0"
          flash[:success] = " Gültiger Plan wurde erstellt."
          valid_solution2 false
          if feasible SemesterPlan.find(params[:id]).solution
            valid_solution2 true
          end
          redirect_to valid_path User.find(params[:id])
      when "1"
          flash[:success] = " 1 verlinkt!"
      when "2"
          flash[:success] = " 2 verlinkt!"
    end



  end

  # gets the index of a slot type.
  # e.g. Montag and 8:00 => 0
  # e.g. Montag and 10:00 => 1 ...
  def slot_type(slot)
    type = 0
    day_mult = 1
    time_mult = 1
    case slot.day
      when "Montag"
        day_mult = 0
      when "Dienstag"
        day_mult = 1
      when "Mittwoch"
        day_mult = 2
      when "Donnerstag"
        day_mult = 3
      when "Freitag"
        day_mult = 4
    end

    case slot.start
      when 8
        time_mult = 0
      when 10
        time_mult = 1
      when 12
        time_mult = 2
      when 14
        time_mult = 3
    end
    return time_mult + 4 * day_mult

  end


  # calculates a valid solution
  def valid_solution2 co_support
    # Randomgenerator
    rnd = Random.new

    # current plan to slove
    plan = SemesterPlan.find(params[:id])

    # prioritys for slots and user
    # sorts slots by user availability
    # sorts user by slot availibiluity
    slot_priority_origin = plan.get_slot_priority
    user_priority_origin = plan.get_user_priority


    # empty slots to empty solution_slots at each itteration begin
    empty_slots = []
    if co_support
      empty_slots = eval(plan.solution)
    else
      20.times do |n|
        empty_slots << {index: n, user: nil, co: nil, slot: nil}
      end
    end

    # break variable
    done = false

    # availabilty which will be max accepted
    if co_support
      availability = 2
    else
      availability = 1
    end

    # saves itterations
    i = 0

    # iteration border for availibility to increase to 2
    i_av_2 = 400

    # iteration_border for interrupt
    i_max = 800

    # saves the solution
    solution_slots = []

    # until all slots are valid taken
    start = Time.now
    begin
      # counter for open slots
      slots = 20

      # clear solution
      solution_slots = empty_slots.clone

      # clone prioritys and shift-plans
      slot_priority = slot_priority_origin.clone
      user_priority = user_priority_origin.clone
      shifts = User.supporter_amount_of_shifts

      # set break variable to false
      done = false

      # repeat until plan invalid or complete plan valid
      while slot_priority.length != 0 && !done

        # random wheel for all slot prioritys
        roulette = calc_roulette slot_priority


        # random float
        random = rnd.rand
        slot = nil

        # take random slot
        roulette.each do |roul|
          if roul[:value] > random
            slot = slot_priority[roul[:index]]
            break
          end
        end
        p "DER SLOT: #{slot}"

        # saves the found user
        found_user = nil
        #p slot[:slot]
        # return all user with given availbility in current slot
        users = TimeSlot.find(slot[:slot]).get_users availability

        # if at least 1 user found
        if users.length != 0

          # break conditions
          found = false
          nothing = true

          # tests all slots
          user_priority.each do |pr_user|
            if !found

              # tests all available users
              users.each do |slot_user|

                # if user is found and in earlier iterations no user was found for this slot
                if (pr_user[:user] == slot_user && !found) &&(co_support && solution_slots.detect {|s| s[:index] == slot[:index]}[:user] !=slot_user || !co_support)

                  #p "slot: #{slot} #{slot_user} "
                  #p "user: #{}"

                     # saves user for slot
                    if co_support
                      solution_slots.detect {|s| s[:index] == slot[:index]}[:co] = slot_user
                      solution_slots.detect {|s| s[:index] == slot[:index]}[:slot] = slot[:slot]
                    else
                      solution_slots.detect {|s| s[:index] == slot[:index]}[:user] = slot_user
                      solution_slots.detect {|s| s[:index] == slot[:index]}[:slot] = slot[:slot]
                    end



                  # set
                  found = true
                  found_user = pr_user

                  # update shifts
                  shifts = User.reduce_shifts found_user[:user], shifts

                  # remove user from slot_priority and delete user from user_priority
                  #  if all shifts are given
                  shifts.each do |s|
                    if s[:user] == found_user[:user]
                      if s[:shifts] == 0
                        slot_priority = SemesterPlan.kill_user_in_slot_priority found_user[:user], slot_priority
                        user_priority.delete(found_user)
                      end
                    end
                  end

                  # delete slot and sort
                  slot_priority.delete(slot)
                  slot_priority.sort_by! {|item|
                    item[:priority] * -1
                  }
                  #p "slot pri #{slot_priority}"
                  # removes slot from user_priority and sort
                  user_priority = SemesterPlan.kill_slot_in_user_priority slot[:slot], user_priority
                  user_priority.sort_by! {|item|
                    item[:priority] * -1
                  }

                  # decrement slots and set nothing to false for next iteration
                  slots -= 1
                  nothing = false
                  break
                end
              end
            end
          end

          # break if no slot was found
          if nothing == true
            done = true
          end
        # break if no user was found
        else
          done = true
        end
      end
      # break if iteration max is reached
      if Time.now - start > 10
        done = true

      # increment aǘailbility
      elsif Time.now - start > 2
        if availability != 2
          availability = 2
        else
          #availability = 1
        end
      end

      # increment iteration
      i += 1
      p  Time.now - start
    end while  slots > 0 && Time.now - start <=10

    # update solution and return it additionally (r)
    plan.update(solution: "#{solution_slots}")
    solution_slots

  end

  def calc_roulette pri_slot
    roulette = []
    size = pri_slot.length.to_f
    sum = pri_slot.inject(0) {|s, pri|
      s += pri[:priority].to_f * ((size/pri_slot.length.to_f)+1.0)
      size -= 1
      s
    }
    #p "sum #{sum}"
    size = pri_slot.length.to_f
    kumul = 0.0
    pri_slot.each_with_index do  |pri, index|
      #p "DEBUG CALC #{pri[:priority].to_f} * #{((size/pri_slot.length.to_f)+1.0)} / #{sum.to_f}"
      if sum == 0
        kumul += 1
      else
        kumul += (pri[:priority].to_f * ((size/pri_slot.length.to_f)+1.0))/ sum.to_f
      end
      roulette << {index: index, value: kumul, slot: pri[:slot]}
      size -= 1
    end
    #p roulette
    roulette
  end

  def feasible plan
    plani = eval(plan)
    plani.each do |pl|
      if pl[:user] == nil
        return false
      end
    end
    true
  end

  #calculates a valid solution
  def valid_solution
    rnd = Random.new
    # plan to solve
    plan = SemesterPlan.find(params[:id])
    # timeslots in plan
    real_slots = plan.time_slots
    # fill slots with index. 0 => motag 8:00 ...
    empty_slots = []
    20.times do |n|
      empty_slots << {index: n, user: nil}
    end
    # Variables for iteration options
    iteration = 0
    iteration_max = 1000
    availability = 1
    iterations_for_2 = 500
    solution_slots = []
    # repeat until solution found
    begin
      # break varaibale
      apport = false
      open_slots = 20
      # calculates shifts per supporter
      shifts = User.supporter_amount_of_shifts
      solution_slots = empty_slots.clone
      solution_slots.each do |slot|
        if !apport
          users = []

          # get all users for current slot, which are available in the slot
          real_slots.find_by(TimeSlot.find_slot_by_type(slot[:index])).semester_plan_connections.where("availability >= :start AND availability <= :end",
              {start: 1, end: availability}).each do |connection|
            if connection.user.planable?
              users << connection.user
            end
          end

          # break variables
          done = false
          max_trys = users.length * users.length

          # iteration of user-slot-connection-try
          i = 0

          # repeat until max trys reached (apport) or current shift occupied
          while !done
            if users.length != 0
              # select random user
              user = users[rnd.rand(0..users.length()-1)]
              # get shift per supporter for user
              shift = shifts.select{|u| u[:user] == user.id}
              # allocate user to slot(shift)
              slot[:user] = user.id

              # test if users has shifts left
              if shift.first[:shifts] != 0
                open_slots -= 1
                shift.first[:shifts] -= 1
                done = true
              end
              # break condition
              if i >= max_trys
                done = true
                apport = true
              end
            end
            i += 1
          end
        end

      end

      # increase iteration and test if availablity 2 is ok until now
      iteration += 1
      if iteration == iterations_for_2
        availability = 2
      end
    # break condition
    end while open_slots > 0 && iteration < iteration_max

    # return
    plan.update(solution: "#{solution_slots}")
  end


end
