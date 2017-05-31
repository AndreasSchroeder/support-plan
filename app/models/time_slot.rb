class TimeSlot < ApplicationRecord
  has_many :semester_plan_connections
  belongs_to :semester_plan

  # returns day and start time by index/type of slot
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

  # return day
  def self.get_day(type)
    day = 0
    while type >= 4
      type -= 4
      day += 1
    end
    days = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"]
    days[day]
  end

  # returns time as strings
  def self.get_time(type)
    while type >= 4
      type -= 4
    end
    start = (type.to_i() * 2) +8
    "#{start}:00 - #{start+2}:00"
  end

  def get_priority
    self.semester_plan_connections.inject(0) {|sum, x| sum + x.availability}
  end

  def get_type
    self.semester_plan_connections.first.typus
  end

    def get_users(av)
    users = []
    self.semester_plan_connections.each do |c|
      if c.availability >= 1 && c.availability <= av
        users << c.user.id
      end
    end
    users
  end
end
