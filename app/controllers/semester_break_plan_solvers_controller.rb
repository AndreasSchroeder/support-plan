class SemesterBreakPlanSolversController < ApplicationController
  before_action :admin_user, only: [:solve, :update]
  before_action :set_plan, only: [:solve, :show, :update, :fix, :fixed]

  def show
    @sol = eval(@plan.solution)
  end

  def solve
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

  def fix
    @plan.update(fixed_solution: @plan.solution)
    flash[:success] = "Gespeichert."
    redirect_to action: 'show'
  end

  def fixed
    @sol = eval(@plan.fixed_solution)
    render template: "semester_break_plans/show"
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
