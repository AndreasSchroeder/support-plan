class SemesterBreakPlanSolversController < ApplicationController
  before_action :admin_user, only: [:solve]

  def solve
  	@plan = SemesterBreakPlan.find(params[:id])
  	@plan.solve(0)
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
