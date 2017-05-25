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

  def show
    @plan = SemesterPlan.find(params[:id])
    @users = User.where(planable: true)
    @slots = []
    @users.each do |user|
      found = !SemesterPlanConnection.are_build?(user, @plan)
      @plan.time_slots.each do |slot|
        if found
          @slots << SemesterPlanConnection.create(user: user, time_slot: slot, availability: 0)
        else
          @slots << SemesterPlanConnection.find_it(user, slot)
        end
      end
    end
  end

  def connect
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
    redirect_to action: "show"
  end

  private
  def plan_params
    params.require(:semester_plan).permit(:start, :end, :name)
  end
end
