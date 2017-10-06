class SemesterPlanManualsController < ApplicationController
  def edit

  end

  def create
    @plan = SemesterPlan.find(params[:id])
    @solution = eval(@plan.solution)

    origin = eval(@plan.solution)
    params["semester_plan"].each do |key, value|
      type = key.split(";").first
      index = key.split(";").last
      if value == ""
        value = nil
      end
      if type == "1"
        slot = @solution.detect {|s| s[:index].to_i == index.to_i}
        slot[:user] = value
      elsif type == "2"
        slot = @solution.detect {|s| s[:index].to_i == index.to_i}
        slot[:co] = value
      end
    end
    break_this = false
    without_error = []
    @solution.zip origin.each do | sol, ori|
      if sol[:user] == sol[:co]
        without_error << ori
        break_this = true
      else
        without_error << sol
      end
    end
    @plan.update(solution: "#{without_error}")
    if !break_this
      flash[:success] = "Neue Werte übernommen."
    else
      flash[:warning] = "Support und Co-Supporter müssen sich unterscheiden!Betroffene Zeilen nicht übernommen."
    end
    redirect_to valid_path(@plan, show_new: true)
  end

  # action for showing a valid solution
  def show
    @plan = SemesterPlan.find(params[:id])

    @users = []
    @scores = @plan.best_meeting_dates
    @users = User.users_of_plan @plan
    @solution = eval(@plan.solution)
    if @plan.fixed_solution

      @fixed_solution = eval(@plan.fixed_solution)
    else
      @fixed_solution = nil
    end
    if params[:show_new]
      @show_solution = @solution
    else
      @show_solution =@fixed_solution
    end
  end

  def update
    @plan = SemesterPlan.find(params[:id])
    @solution = eval(@plan.solution)
    redirect_to valid_path(@plan)
    if @plan.update(fixed_solution: "#{@solution}")
      @fixed_solution = eval(@plan.fixed_solution)

      flash[:success] = "Neue Belegung für Plan gespeichert #{ @plan.get_fitness_of_solution @fixed_solution}."
    else
      flash[:success] = "Es ist ein Fehler aufgetreten."
    end

  end

end
