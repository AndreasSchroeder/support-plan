class SemesterBreakPlanSolversController < ApplicationController
  before_action :admin_user, only: [:solve]

  def show
    @plan = SemesterBreakPlan.find(params[:id])
    p "IN SHOW #{@plan.solution}"

  end

  def solve
  	@plan = SemesterBreakPlan.find(params[:id])
  	@plan.solve(0)
    p "IN SOLVES #{@plan.solution}"
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
end
