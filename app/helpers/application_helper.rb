module ApplicationHelper
    def get_collection s, co, plan
    @collection = []
    users = User.users_of_plan_without_office plan
    selected = false
    users.each do |user|
      if s[:user].to_i == user.id && !co
        selected = true
        @collection << [user.get_name_or_alias, user.id, {class: "av#{SemesterPlanConnection.find_it_id(user.id, (s[:slot].to_i())).availability}", selected: "" }]
      elsif s[:co].to_i == user.id && co
        selected = true
        @collection << [user.get_name_or_alias, user.id, {class: "av#{SemesterPlanConnection.find_it_id(user.id, (s[:slot].to_i())).availability}", selected: "" }]
      elsif s[:slot]
        @collection << [user.get_name_or_alias, user.id, {class: "av#{SemesterPlanConnection.find_it_id(user.id, (s[:slot].to_i())).availability}" }]
      else
        @collection << [user.get_name_or_alias, user.id]
      end
    end
    if !selected
      @collection << ["(niemand)", nil, {selected: ""}]
    else
      @collection << ["(niemand)", nil]
    end
    @collection
  end

  def get_av s, co
    if co && s[:co]
      return "av#{SemesterPlanConnection.find_it_id(s[:co].to_i, (s[:slot].to_i())).availability}"
    elsif !co && s[:user]
      return "av#{SemesterPlanConnection.find_it_id(s[:user].to_i, (s[:slot].to_i())).availability}"
    end
    return ""
  end

  def get_av_user_slot user, slot
    return "av#{SemesterPlanConnection.find_it(user, slot).availability}"
  end

  def meeting_collection scores, plan
    @collection = []
    selected = false
    day = plan.meeting_day
    time = plan.meeting_time

    scores.each do |score|
      if score[:slot][:day] == day && score[:slot][:start].to_i == time.to_i
        selected = true
        @collection << ["#{score[:slot][:day]} #{score[:slot][:start]}:00Uhr (#{score[:score]})", "#{score[:slot][:day]};#{score[:slot][:start]}", {selected: ""}]
      else
        @collection << ["#{score[:slot][:day]} #{score[:slot][:start]}:00Uhr (#{score[:score]})", "#{score[:slot][:day]};#{score[:slot][:start]}"]
      end
      if score[:slot][:day] == day && score[:slot][:start].to_i + 1 == time.to_i
        selected = true
        @collection << ["#{score[:slot][:day]} #{score[:slot][:start] + 1}:00Uhr (#{score[:score]})", "#{score[:slot][:day]};#{score[:slot][:start] + 1}", {selected: ""}]
      else
        @collection << ["#{score[:slot][:day]} #{score[:slot][:start] + 1}:00Uhr (#{score[:score]})", "#{score[:slot][:day]};#{score[:slot][:start] + 1}"]
      end
    end
    if !selected
      @collection << ["(nichts ausgewählt)", nil, {selected: ""}]
    else
      @collection << ["(nichts ausgewählt)", nil]
    end
    @collection
  end

  def german_time time
    if time
      return time.strftime("%H:%M:%S Uhr, %d.%m.%Y")
    else
      return "Keine Zeit vorhanden"
    end
  end

  def german_day time
    if time
      return time.strftime("%d.%m.%Y")
    else
      return "Keine Zeit vorhanden"
    end
  end

  def german_dayname time
    if time
      dayname= ""
      case time.wday
      when 0
        dayname = "So"
      when 1
        dayname = "Mo"
      when 2
        dayname = "Di"
      when 3
        dayname = "Mi"
      when 4
        dayname = "Do"
      when 5
        dayname = "Fr"
      when 6
        dayname = "Sa"
      end                                        
      return "#{dayname} #{time.strftime('%d.%m.%Y')}"
    else
      return "Keine Zeit vorhanden"
    end
  end

  def parse_day time
    if time
      return time.strftime("%Y-%m-%d")
    else
      return "Keine Zeit vorhanden"
    end
  end

end
