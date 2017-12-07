class DayWeek

  def initialize(days)
    @days = days
  end

  def self.generate_weeks(days)
    weeks = []
    alld = days.group_by{|day| day.start.strftime('%U').to_i}.map { |key, value| value }
    alld.each do |week|
        weeks << new(week)
    end
    weeks
  end

  def days
    @days
  end

  # finds the best match in the week for the user. A best match has as many
  # following days with given availability as possible
  def best_for_users users, av
    last = nil
    best = []
    users.each do |user|
      row = []
      matches = []
      self.days.each do |day|
        slot = day.semester_break_plan_connections.detect {|con| con.user == user}
        if slot.availability.to_i != 0 && slot.availability.to_i <= av
            row << day.id
        else
          if row.any?
            matches << row
          end
          row = []
        end
      end
      if row != matches.last
        matches << row
      end
      best << {user: user.id, days: matches.sort_by{|row| row.length * (-1)}.first}
    end
    best.sort_by{|user| user[:days].length() * (-1)}
  end
end
