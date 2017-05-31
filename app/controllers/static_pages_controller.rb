class StaticPagesController < ApplicationController
  # home
  def home
    if !logged_in?
      redirect_to login_path
    end
    @plans = SemesterPlan.all
  end
end
