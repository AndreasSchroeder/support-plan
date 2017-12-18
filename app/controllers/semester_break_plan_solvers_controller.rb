class SemesterBreakPlanSolversController < ApplicationController
  before_action :admin_user, only: [:solve]

  def show
    @plan = SemesterBreakPlan.find(params[:id])

  end

  def solve
  	@plan = SemesterBreakPlan.find(params[:id])
  	@plan.solve(params[:type].to_i)
    redirect_to action: 'show'
  end

  def update
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
end
