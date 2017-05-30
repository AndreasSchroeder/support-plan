require 'json'
class SemesterPlansController < ApplicationController
  def new
    @plan = SemesterPlan.new
  end

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
  def valid
    @plan = SemesterPlan.find(params[:id])
    @solution = eval(@plan.solution)
  end

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
  def handle
    if params["connections"]
      connect(params)
    elsif params["optimisation"]
      optimize(params)
    elsif params["free"]
      flash[:success] = "Plan zur Bearbeitung freigegeben"
      SemesterPlan.find(params[:id]).update(free: true)
    end
    redirect_to action: "show"

  end

  

  private
  def plan_params
    params.require(:semester_plan).permit(:start, :end, :name)
  end

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

  def optimize(params)
    case params["optimisation"]["kind"]
      when "0"
          flash[:success] = " 0 verlinkt!"
          p "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          p valid_solution
      when "1"
          flash[:success] = " 1 verlinkt!"
      when "2"
          flash[:success] = " 2 verlinkt!"
    end



  end

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




  def valid_solution
    rnd = Random.new
    plan = SemesterPlan.find(params[:id])
    real_slots = plan.time_slots
    empty_slots = []
    20.times do |n|
      empty_slots << {index: n, user: nil}
    end
    iteration = 0
    iteration_max = 1000
    availability = 1
    iterations_for_2 = 500
    solution_slots = []
    begin
      p iteration
      apport = false
      open_slots = 20
      shifts = User.supporter_amount_of_shifts
      solution_slots = empty_slots.clone
      solution_slots.each do |slot|
        if !apport 
          users = []

          real_slots.find_by(TimeSlot.find_slot_by_type(slot[:index])).semester_plan_connections.where("availability >= :start AND availability <= :end",
              {start: 0, end: availability}).each do |connection|
            if connection.user.planable?
              users << connection.user
            end
          end
          done = false
          max_trys = users.length * users.length
          i = 0
          while !done 
            if users.length != 0
              user = users[rnd.rand(0..users.length()-1)]
              p user
              shift = shifts.select{|u| u[:user] == user.id}
              p shift
              slot[:user] = user.id
              if shift.first[:shifts] != 0
                open_slots -= 1
                shift.first[:shifts] -= 1
                done = true
              end
              if i >= max_trys
                done = true
                apport = true
              end
            end
            i += 1
          end
        end

      end

      iteration += 1
      if iteration == iterations_for_2
        availability = 2
      end
    end while open_slots > 0 && iteration < iteration_max
    p "EEEEEEEEEEEEEEEEEEEEEEEEEENNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNDD"
    p solution_slots
    plan.update(solution: "#{solution_slots}")
  end


end
