# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
def parse_day time
    if time
      return time.strftime("%Y-%m-%d")
    else
      return "Keine Zeit vorhanden"
    end
  end
ran = Random.new

User.create(email: "admin@admintest.de", is_admin: true, first_name: "admin", planable: false)
User.create(email: "andschroeder@uos.de", is_admin: true, first_name: "andi", last_name: "schroeder", hours: 40)
9.times do |n|
  User.create(first_name: "Jack#{n}",last_name: "#{n}", email: "jack#{n}@uos.de", hours: 30)
end
User.create(first_name: "Jack9", last_name: "9", email: "jack9@uos.de", hours: 20)


@plan = SemesterPlan.create(name: "Supportplan", start: Time.now, end: Time.now)
["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"].each do |day|
  start_time = 8
  4.times do
    timeslot = @plan.time_slots.create!(start: start_time, end: start_time + 2, day: day)
    start_time += 2
  end
end
@users = User.where(planable: true)
@slots = []
@users.each do |user|
  found = !SemesterPlanConnection.are_build?(user, @plan)
  @plan.time_slots.each do |slot|
    type = 0
    day_mult = 1
    time_mult = 1
    case slot.day
    when "Montag"
      day_mult = 0
    when "Dienstag"
      day_mult = 1
    when "Mittwoch"
      day_mult = 2
    when "Donnerstag"
      day_mult = 3
    when "Freitag"
      day_mult = 4
    end

    case slot.start
    when 8
      time_mult = 0
    when 10
      time_mult = 1
    when 12
      time_mult = 2
    when 14
      time_mult = 3
    end
    type = time_mult + 4 * day_mult
    av = 0
    if found
      @slots << SemesterPlanConnection.create(user: user, time_slot: slot, typus: type, availability: (ran.rand(0..2)%3)+1)
    else
      @slots << SemesterPlanConnection.find_it(user, slot)
    end
  end
end

@plan = SemesterPlan.create(name: "Supportplan", start: Time.now, end: Time.now)
["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"].each do |day|
  start_time = 8
  4.times do
    timeslot = @plan.time_slots.create!(start: start_time, end: start_time + 2, day: day)
    start_time += 2
  end
end
@users = User.where(planable: true)
@slots = []
@users.each do |user|
  found = !SemesterPlanConnection.are_build?(user, @plan)
  @plan.time_slots.each do |slot|
    type = 0
    day_mult = 1
    time_mult = 1
    case slot.day
    when "Montag"
      day_mult = 0
    when "Dienstag"
      day_mult = 1
    when "Mittwoch"
      day_mult = 2
    when "Donnerstag"
      day_mult = 3
    when "Freitag"
      day_mult = 4
    end

    case slot.start
    when 8
      time_mult = 0
    when 10
      time_mult = 1
    when 12
      time_mult = 2
    when 14
      time_mult = 3
    end
    type = time_mult + 4 * day_mult
    av = 0
    if found
      @slots << SemesterPlanConnection.create(user: user, time_slot: slot, typus: type, availability: (ran.rand(0..2)%3)+1)
    else
      @slots << SemesterPlanConnection.find_it(user, slot)
    end
  end
end

@start = Time.new(2017,12,4)
@ends = Time.new(2018,02,23)
@break_plan = SemesterBreakPlan.create(name: "Test", start: @start, end: @ends)

@users = User.users_of_break_plan @break_plan
days = DaySlot.days_between @break_plan.start, @break_plan.end
days.each do |day|
  slot = @break_plan.day_slots.create(start: parse_day(day))
  @users.each do |user|
    slot.semester_break_plan_connections.create(user: user, availability: (ran.rand(0..2)%3)+1)
  end
end

