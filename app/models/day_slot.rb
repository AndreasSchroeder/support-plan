class DaySlot < ApplicationRecord
  has_many :semester_break_plan_connections
  belongs_to :semester_break_plan


  def self.days_between start, ends
  	days = []
  	(start..ends).each do |day|
  		if !(day.wday == 0 || day.wday == 6 )
  			if Holiday.all.detect{|holiday|holiday.day == day}.nil?
  				days << day
  			end
  		end
  	end
  	days
  end

  def delete_if_holiday
  	if !Holiday.all.detect{|holiday| holiday.day == self.start}.nil?
  		DaySlot.find(self).destroy!()
  	end
  end

  def create_holiday
  	Holiday.create(day: self.start, name: "Feiertag/Brückentag")
  end
end
