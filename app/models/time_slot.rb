class TimeSlot < ApplicationRecord
  has_many :semester_plan_connections
  belongs_to :semester_plan

  def self.find_slot_by_type(type)
    day = 0
    time = 0
    while type >= 4
      type -= 4
      day += 1
    end
    days = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"]
    time = (type *2) +8
    {day: days[day], start: time}
  end

  def self.get_day(type)
    day = 0
    while type >= 4
      type -= 4
      day += 1
    end
    days = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"]
    days[day]
  end

  def self.get_time(type)
    while type >= 4
      type -= 4
    end
    start = (type.to_i() * 2) +8
    "#{start}:00 - #{start+2}:00"
  end
end
