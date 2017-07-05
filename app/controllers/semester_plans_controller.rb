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


  # action for showing a plan. Users are able to fill in Shiftavailibility
  def show
    @plan = SemesterPlan.find(params[:id])
    @users = User.where(planable: true)
    @slots = []
    @options = {0 => "manuellen Plan erstellen", 1 => "gültige Lösungen berechnen lassen", 2 => "hinreichend optimale Lösung berechnen lassen"}
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
    plan = SemesterPlan.find(params[:id])
    case params["optimisation"]["kind"]
      when "0"
        if plan.solution.nil?
          empty_slots = []
          plan.time_slots.each_with_index do |n, index|
            empty_slots << {index: index, user: nil, co: nil, slot: n.id}
          end
          plan.update(solution: empty_slots)
        end
        flash[:success] = " Manuelle Planerstellung eingeleitet"
          redirect_to valid_path User.find(params[:id])
      when "1"
        flash[:success] = " Gültiger Plan wurde erstellt."
        plan.update(solution: "#{valid_solution2 false}")
        p "Soltuion: #{plan.solution}"

        if feasible plan.solution
          plan.update(solution: "#{valid_solution2 true}")
        end
        redirect_to valid_path User.find(params[:id])
      when "2"
        plan.update(solution: "#{heuristic (plan)}")
        p "Soltuion: #{plan.solution}"
        if feasible plan.solution
          plan.update(solution: "#{valid_solution2 true}")
        end
        flash[:success] = " 2 verlinkt!"
        redirect_to semester_plan_path


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

  def heuristic plan
    solutions = start_solution plan
    50.times do
      parents = selection plan, solutions
      solutions << generate_child_solution(plan, parents)
      solutions = sort_soluitons(plan, solutions).first(10)
    end
    solutions.first
  end

  # Selecte two best of four random
  def selection plan, solutions
    (sort_soluitons plan, solutions.shuffle.first(4)).first(2)
  end

  def sort_soluitons plan, solutions
    solutions.sort_by{|s| [plan.get_fitness_of_solution(s)[:fitness] * -1, plan.get_fitness_of_solution(s)[:unfitness].to_i]}
  end

  def generate_child_solution plan, parents
    father = parents[0]
    mother = parents[1]

    child_one = father.first(10)
    child_two = mother.first(10)
    father_rest = father.last(10)
    mother_rest = mother.last(10)
    last = child_one.last
    mother.each_with_index do |m, index|
      if father_rest.any?
        element = father_rest.detect{|x| x[:user]==m[:user]}
        if element
          slot = father.detect{|x| x[:index].to_i == last[:index].to_i + 1}[:slot].to_i
          child_one << {index: last[:index] + 1, user: m[:user].to_i, co: nil, slot: slot}
          father_rest.delete(element)
          last = child_one.last
        end
      end
    end
    last = child_two.last
    father.each_with_index do |m, index|
      if mother_rest.any?
        element = mother_rest.detect{|x| x[:user]==m[:user]}
        if element
          slot = father.detect{|x| x[:index].to_i == last[:index].to_i + 1}[:slot].to_i
          child_two << {index: last[:index].to_i + 1, user: m[:user].to_i, co: nil, slot: slot}
          mother_rest.delete(element)
          last = child_two.last
        end
      end
    end
    mutate plan, sort_soluitons(plan, [child_one, child_two]).first

  end

  def mutate plan, child
    child
  end

  # Calculates 20 Start solutions
  def start_solution plan
    solutions = []
    1.times do
      s = valid_solution2(false)
      solutions << s
    end

    10.times do
      s = random_solution plan
      solutions << s
    end
    sort_soluitons plan, solutions
  end

  def random_solution plan
    user = []
    User.supporter_amount_of_shifts.each do  |s|
      s[:shifts].to_i.times do
        user << s[:user].to_i
      end
    end
    user.shuffle!
    empty_slots = []
    plan.time_slots.each_with_index do |slot, index|
      empty_slots << {index: index, user: user[index].to_i, co: nil, slot: slot.id}
    end
    empty_slots

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
    end while  slots > 0 && Time.now - start <=10

    # update solution and return it additionally (r)
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



end
