class SemesterPlanManualsController < ApplicationController
  def edit

  end

  def create
    @plan = SemesterPlan.find(params[:id])
    p params["semester_plan"]
    @solution = eval(@plan.solution)
    break_this = false
    params["semester_plan"].each do |key, value|
      type = key.split(";").first
      index = key.split(";").last
      if value == ""
        value = nil
      end
      if type == "1"
        slot = @solution.detect {|s| s[:index].to_i == index.to_i}
        if slot[:co] != value
          slot[:user] = value
        else

          break_this = true
        end
      elsif type == "2"
        slot = @solution.detect {|s| s[:index].to_i == index.to_i}
        if slot[:user] != value
          slot[:co] = value
        else
          break_this = true
        end
      end
    end
    if !break_this
      @plan.update(solution: "#{@solution}")
    else
        flash[:warning] = "Abgebrochen! Support und Co-Supporter müssen sich unterscheiden"
    end
    redirect_to valid_path(@plan)
  end

  # action for showing a valid solution
  def show
    @plan = SemesterPlan.find(params[:id])
    @users = User.where(planable: true)
    @solution = eval(@plan.solution)


  end

end
