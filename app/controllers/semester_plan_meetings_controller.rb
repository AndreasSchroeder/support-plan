class SemesterPlanMeetingsController < ApplicationController

# action for showing a valid solution
  def create
    @plan = SemesterPlan.find(params[:id])
    day =params["meeting"]["meeting_day"].split(";").first
    time =params["meeting"]["meeting_day"].split(";").second
    if @plan.update(meeting_day: day, meeting_time: time.to_i)
      flash[:success] = "Termin Festgelegt."
    else
      flash[:warning] = "Festlegen fehlgeschlagen."
    end
    redirect_to valid_path(@plan)
  end
end
