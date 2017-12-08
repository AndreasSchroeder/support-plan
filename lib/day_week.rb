class DayWeek

  def initialize(days)
    @days = days.to_a
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

  def remove_days days
    #p "days: #{days}, @day: #{@days}"
    reject = []
    days.each do |day|
      @days.delete_if {|v| reject << v if v[:id] == day}
    end
    #p "reject: #{reject}"
  end

  # finds the best match in the week for the user. A best match has as many
  # following days with given availability as possible
  def best_for_users users, av
    last = nil
    best = []
    users.each do |user|
      best << best_for_user(user, av)
    end
    best.sort_by{|user| user[:days].first.length() * (-1)}
  end

  def best_for_user user, av
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
    if row != matches.last && row != []
      matches << row
    end
    if matches == []
      matches = [[]]
    end
    {user: user.id, days: matches.sort_by{|row| row.length * (-1)}}
  end
end
