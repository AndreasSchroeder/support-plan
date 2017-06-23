class SemesterPlanManualsController < ApplicationController
  def edit

  end

  def create
    @plan = SemesterPlan.find(params[:id])
    p @plan.name
    redirect_to valid_path(@plan)
  end
end
