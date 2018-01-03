class StaticPagesController < ApplicationController
  # home
  def home
    if !logged_in?
      redirect_to login_path
    end
    @plans = SemesterPlan.where(inactive: false)
    @plans_break = SemesterBreakPlan.where(inactive: false)
  end
end
