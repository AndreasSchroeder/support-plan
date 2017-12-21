class SemesterBreakPlanSolversController < ApplicationController
  before_action :admin_user, only: [:solve, :update]
  before_action :set_plan, only: [:solve, :show, :update]

  def show
    @plan = SemesterBreakPlan.find(params[:id])

  end

  def solve
  	@plan = SemesterBreakPlan.find(params[:id])
  	@plan.solve(params[:type].to_i)
    redirect_to action: 'show'
  end

  def update
    sol = eval(@plan.solution)
    params["semester_break_plan"].each do |key, value|
      sol.detect{|d| d[:slot].to_i == key.to_i}[:user] = value
    end
    @plan.update(solution: "#{sol}")
    flash[:success] = "Gespeichert."
    redirect_to action: 'show'
  end

  private
   	# Confirms an admin user.
    def admin_user
      unless current_user.is_admin?
        flash[:danger] = "Keine Berechtigung."
        redirect_to(root_url)
      end
    end

    def set_plan
      @plan = SemesterBreakPlan.find(params[:id])

    end
end
