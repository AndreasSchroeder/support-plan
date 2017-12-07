class Week

  def initialize(days)
    @days = days
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
        slot = day.semester_break_plans.detect {|con| con.user == user}
        if slot.availability != 0 && slot.availability <= av
            row << day
        else
          matches << row
          row = []
        end
      end
      best << matches.order_by{|row| row.length}.first
    end
    best
  end
end
