class SemesterPlanManualsController < ApplicationController
  def edit

  end

  def create
    @plan = SemesterPlan.find(params[:id])
    p params["semester_plan"]
    @solution = eval(@plan.solution)
    params["semester_plan"].each do |key, value|
      type = key.split(";").first
      index = key.split(";").last
      if value == ""
        value = nil
      end
      if type == "1"
        @solution.detect {|s| s[:index].to_i == index.to_i}[:user] = value
      elsif type == "2"
        @solution.detect {|s| s[:index].to_i == index.to_i}[:co] = value
      end
    end
    @plan.update(solution: "#{@solution}")
    redirect_to valid_path(@plan)
  end

  # action for showing a valid solution
  def show
    @plan = SemesterPlan.find(params[:id])
    @users = User.where(planable: true)
    @solution = eval(@plan.solution)


  end

end
