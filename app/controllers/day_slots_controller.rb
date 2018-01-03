class DaySlotsController < ApplicationController
  def destroy
  	slot= DaySlot.find(params[:id])
  	slot.create_holiday
  	slot.semester_break_plan_connections.each do |con|
  		con.destroy
  	end
  	slot.destroy

  	flash[:success] = "Erfolgreich als Feiertag/Brückentag eingetragen."
	redirect_to semester_break_plan_path params[:plan_id]
  end
end
